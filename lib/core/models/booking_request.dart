import 'dart:convert';

/// Where a request has got to. Until the backend owns bookings, the app only
/// ever sets [requested] — the rest come from the venue, so nothing here
/// claims a slot is held.
enum BookingStatus { requested, confirmed, declined, cancelled }

/// One booking a customer has asked for: which service, when, for how many.
class BookingRequest {
  final String id;
  final String serviceId;
  final String serviceName;
  final String zoneId;
  final String zoneName;

  /// The day, with no time on it.
  final DateTime day;

  /// The arrival time, already formatted for the customer's locale, because
  /// that is also exactly what the venue reads in the message.
  final String time;

  final int people;
  final String? note;
  final double? price;
  final BookingStatus status;
  final DateTime createdAt;

  const BookingRequest({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.zoneId,
    required this.zoneName,
    required this.day,
    required this.time,
    required this.people,
    required this.createdAt,
    this.note,
    this.price,
    this.status = BookingStatus.requested,
  });

  /// A new request, with an id built from the clock so it sorts by age.
  factory BookingRequest.create({
    required String serviceId,
    required String serviceName,
    required String zoneId,
    required String zoneName,
    required DateTime day,
    required String time,
    required int people,
    String? note,
    double? price,
  }) {
    final now = DateTime.now();
    return BookingRequest(
      id: 'bk-${now.microsecondsSinceEpoch}',
      serviceId: serviceId,
      serviceName: serviceName,
      zoneId: zoneId,
      zoneName: zoneName,
      day: DateTime(day.year, day.month, day.day),
      time: time,
      people: people,
      note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      price: price,
      createdAt: now,
    );
  }

  BookingRequest copyWith({BookingStatus? status}) => BookingRequest(
        id: id,
        serviceId: serviceId,
        serviceName: serviceName,
        zoneId: zoneId,
        zoneName: zoneName,
        day: day,
        time: time,
        people: people,
        note: note,
        price: price,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'zoneId': zoneId,
        'zoneName': zoneName,
        'day': day.toIso8601String(),
        'time': time,
        'people': people,
        if (note != null) 'note': note,
        if (price != null) 'price': price,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Tolerant of anything missing, so one bad record cannot empty the list.
  static BookingRequest? tryFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final day = DateTime.tryParse(json['day']?.toString() ?? '');
    if (id == null || day == null) return null;
    return BookingRequest(
      id: id.toString(),
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? 'Booking',
      zoneId: json['zoneId']?.toString() ?? '',
      zoneName: json['zoneName']?.toString() ?? '',
      day: day,
      time: json['time']?.toString() ?? '',
      people: int.tryParse(json['people']?.toString() ?? '') ?? 1,
      note: json['note']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? ''),
      status: BookingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => BookingStatus.requested,
      ),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? day,
    );
  }

  String encode() => jsonEncode(toJson());

  static BookingRequest? decode(String raw) {
    try {
      final json = jsonDecode(raw);
      return json is Map<String, dynamic> ? tryFromJson(json) : null;
    } catch (_) {
      return null;
    }
  }
}
