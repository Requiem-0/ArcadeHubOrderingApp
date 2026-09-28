import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../models/booking_request.dart';
import 'auth_repository.dart';

/// Thrown when a request could not be handed over. The caller shows the
/// venue's number so the customer still has a way through.
class BookingDeliveryException implements Exception {
  final String message;
  const BookingDeliveryException(this.message);

  @override
  String toString() => message;
}

/// How bookings leave the app. One implementation today, over WhatsApp;
/// swapping in an API one later should not touch a screen.
abstract class BookingRepository {
  /// Hands the request to the venue and keeps a copy for the customer.
  Future<BookingRequest> submit(BookingRequest request);

  /// The customer's own requests, newest first.
  Future<List<BookingRequest>> mine();

  /// Marks a request cancelled locally. The venue is told in the chat.
  Future<void> cancel(String id);

  /// Days that are already taken for a zone. Nothing knows this yet, so the
  /// calendar greys nothing out.
  Future<Set<DateTime>> unavailable({required String zoneId});
}

/// Sends the request to the venue's WhatsApp, because the POS has no
/// customer-facing booking API: staff read the message and enter it
/// themselves. The copy kept here is what lets the app show the customer
/// their own request afterwards — it is a record of what was asked for,
/// never proof that the slot is held.
class WhatsAppBookingRepository implements BookingRepository {
  static const String _prefsKey = 'arcade_hub_booking_requests';

  /// Who the request is addressed to, and who opens the link. Swapped out in
  /// tests so nothing tries to launch WhatsApp there.
  final Future<bool> Function(Uri uri) launcher;
  final String? senderName;

  WhatsAppBookingRepository({
    Future<bool> Function(Uri uri)? launcher,
    this.senderName,
  }) : launcher = launcher ??
            ((uri) => launchUrl(uri, mode: LaunchMode.externalApplication));

  @override
  Future<BookingRequest> submit(BookingRequest request) async {
    final opened = await launcher(whatsappUriFor(request, name: senderName));
    if (!opened) {
      throw BookingDeliveryException(
        'Could not open WhatsApp. Call ${AppConstants.bookingWhatsappFormatted}.',
      );
    }
    // Saved only once it is on its way, so a failed hand-off leaves no
    // request the customer thinks the venue has seen.
    final all = await mine();
    await _write([request, ...all]);
    return request;
  }

  @override
  Future<List<BookingRequest>> mine() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefsKey) ?? const [];
      final found = <BookingRequest>[];
      for (final line in raw) {
        final parsed = BookingRequest.decode(line);
        if (parsed != null) found.add(parsed);
      }
      found.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return found;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> cancel(String id) async {
    final all = await mine();
    await _write([
      for (final r in all)
        r.id == id ? r.copyWith(status: BookingStatus.cancelled) : r,
    ]);
  }

  @override
  Future<Set<DateTime>> unavailable({required String zoneId}) async => const {};

  Future<void> _write(List<BookingRequest> requests) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _prefsKey,
        [for (final r in requests) r.encode()],
      );
    } catch (_) {
      // A failed write costs the local copy, not the booking itself.
    }
  }
}

/// The WhatsApp link that carries a booking request: everything the venue
/// needs to enter it in the POS, one line each.
Uri whatsappUriFor(BookingRequest r, {String? name}) {
  final hasName = name != null && name.trim().isNotEmpty;
  final lines = [
    'Booking request',
    '',
    '${r.serviceName} - ${r.zoneName}',
    '${DateFormat('EEE d MMM').format(r.day)}, ${r.time}',
    '${r.people} ${r.people == 1 ? 'person' : 'people'}',
    if (r.price != null) 'Listed at ${AppConstants.formatPrice(r.price!)}',
    if (r.note != null) 'Note: ${r.note}',
    if (hasName) '',
    if (hasName) name.trim(),
  ];
  final digits = AppConstants.bookingWhatsapp.replaceAll(RegExp(r'[^0-9]'), '');
  return Uri.parse(
    'https://wa.me/$digits?text=${Uri.encodeComponent(lines.join('\n'))}',
  );
}

/// The signed-in customer's name rides along in the message when there is one.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final name = ref.watch(currentUserProvider).valueOrNull?.name;
  return WhatsAppBookingRepository(senderName: name);
});

final myBookingsProvider = FutureProvider<List<BookingRequest>>((ref) async {
  return ref.watch(bookingRepositoryProvider).mine();
});
