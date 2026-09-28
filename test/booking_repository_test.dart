import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arcadehuborderingapp/core/models/booking_request.dart';
import 'package:arcadehuborderingapp/core/repositories/booking_repository.dart';

void main() {
  BookingRequest sample({int people = 3, String? note, double? price}) =>
      BookingRequest.create(
        serviceId: 'srv-ps5',
        serviceName: 'PS5 Console Rental',
        zoneId: 'playroom',
        zoneName: 'Play Room',
        day: DateTime(2026, 10, 4),
        time: '9:00 PM',
        people: people,
        note: note,
        price: price,
      );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the WhatsApp message', () {
    test('carries everything the venue has to type in', () {
      final uri = whatsappUriFor(
        sample(note: 'Birthday', price: 2000),
        name: 'Sarip',
      );
      final text = uri.queryParameters['text']!;

      expect(uri.host, 'wa.me');
      // Digits only with the country code, the way wa.me wants it. Which
      // number it is can change while testing.
      expect(uri.path, matches(RegExp(r'^/977[0-9]{9,10}$')));
      expect(text, contains('PS5 Console Rental - Play Room'));
      expect(text, contains('Sun 4 Oct, 9:00 PM'));
      expect(text, contains('3 people'));
      expect(text, contains('Note: Birthday'));
      expect(text.trim().endsWith('Sarip'), isTrue);
    });

    test('leaves out what was not given', () {
      final text = whatsappUriFor(sample(people: 1, note: '   '))
          .queryParameters['text']!;

      expect(text, contains('1 person'));
      expect(text, isNot(contains('Listed at')));
      expect(text, isNot(contains('Note:')));
    });
  });

  group('submitting', () {
    test('keeps a copy the customer can see afterwards', () async {
      Uri? opened;
      final repo = WhatsAppBookingRepository(launcher: (uri) async {
        opened = uri;
        return true;
      });

      await repo.submit(sample());
      final mine = await repo.mine();

      expect(opened, isNotNull);
      expect(mine, hasLength(1));
      expect(mine.first.serviceName, 'PS5 Console Rental');
      // Nothing is held until the venue says so.
      expect(mine.first.status, BookingStatus.requested);
    });

    test('saves nothing when WhatsApp will not open', () async {
      final repo = WhatsAppBookingRepository(launcher: (_) async => false);

      await expectLater(
        repo.submit(sample()),
        throwsA(isA<BookingDeliveryException>()),
      );
      expect(await repo.mine(), isEmpty);
    });

    test('lists the newest request first', () async {
      final repo = WhatsAppBookingRepository(launcher: (_) async => true);

      await repo.submit(sample(people: 2));
      await repo.submit(sample(people: 8));

      final mine = await repo.mine();
      expect(mine, hasLength(2));
      expect(mine.first.people, 8);
    });

    test('survives a junk record left in storage', () async {
      SharedPreferences.setMockInitialValues({
        'arcade_hub_booking_requests': ['not json at all'],
      });
      final repo = WhatsAppBookingRepository(launcher: (_) async => true);

      await repo.submit(sample());
      expect(await repo.mine(), hasLength(1));
    });
  });

  test('cancelling marks the request, it does not drop it', () async {
    final repo = WhatsAppBookingRepository(launcher: (_) async => true);
    final request = await repo.submit(sample());

    await repo.cancel(request.id);
    final mine = await repo.mine();

    expect(mine, hasLength(1));
    expect(mine.first.status, BookingStatus.cancelled);
  });

  test('nothing is greyed out until the backend knows about bookings',
      () async {
    final repo = WhatsAppBookingRepository(launcher: (_) async => true);
    expect(await repo.unavailable(zoneId: 'playroom'), isEmpty);
  });
}
