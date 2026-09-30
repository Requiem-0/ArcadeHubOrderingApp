import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../brandkit/experiences.dart';
import '../brandkit/zone_features.dart';
import '../models/service.dart';

/// The photo a home-screen feature already uses, so the Book tab is not a
/// second place to keep image URLs. Placeholder stock either way.
String? _featurePhoto(String title) {
  for (final f in kZoneFeatures) {
    if (f.title == title) return f.imageUrl;
  }
  return null;
}

class ServiceRepository {
  // This data would eventually come from the backend.
  static final List<ServiceModel> _all = [
    ServiceModel(
      id: 'srv-ps5',
      imageUrl: _featurePhoto('PS5 Gaming'),
      experienceId: 'playroom',
      name: 'PS5 Console Rental',
      description: 'Overnight gaming pass with up to 4 controllers.',
      price: 2000.0,
      durationText: '9:00 PM → 9:00 AM',
      rules: 'Late returns incur an additional hourly charge. Subject to availability.',
      isBookable: true,
    ),
    ServiceModel(
      id: 'srv-vr',
      imageUrl: _featurePhoto('Racing'),
      experienceId: 'playroom',
      name: 'VR Battle Arena',
      description: '30-minute immersive virtual reality session.',
      price: 500.0,
      durationText: '30 mins',
      isBookable: true,
    ),
    ServiceModel(
      id: 'srv-ps5-area51',
      imageUrl: _featurePhoto('PS5 Gaming'),
      experienceId: 'area51',
      name: 'VIP PS5 Station',
      description: 'Private PS5 gaming in the futuristic lounge.',
      price: 2500.0,
      durationText: '9:00 PM → 9:00 AM',
      isBookable: true,
    ),
    ServiceModel(
      id: 'srv-party',
      imageUrl: _featurePhoto('Private Parties'),
      experienceId: 'partyroom',
      name: 'Private Room Booking',
      description: 'Exclusive use of the party room for celebrations.',
      durationText: 'Per Hour or Full Night',
      isBookable: true,
    ),
  ];

  Future<List<ServiceModel>> getServicesForExperience(String experienceId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 600));
    return _all.where((s) => s.experienceId == experienceId).toList();
  }

  Future<ServiceModel?> getServiceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    for (final s in _all) {
      if (s.id == id) return s;
    }
    return null;
  }
}

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
});

/// The service behind a booking link, with the zone it belongs to, so the
/// booking screen can name what is actually being booked.
final serviceByIdProvider =
    FutureProvider.family<BookableService?, String>((ref, id) async {
  final service = await ref.read(serviceRepositoryProvider).getServiceById(id);
  if (service == null) return null;
  final zone = kArcadeExperiences.firstWhere(
    (e) => e.id == service.experienceId,
    orElse: () => kArcadeExperiences.first,
  );
  return BookableService(service: service, zone: zone);
});

/// A service paired with its zone.
class BookableService {
  final ServiceModel service;
  final ArcadeExperience zone;

  const BookableService({required this.service, required this.zone});
}

final servicesProvider = FutureProvider.family<List<ServiceModel>, String>((ref, experienceId) async {
  return ref.read(serviceRepositoryProvider).getServicesForExperience(experienceId);
});

/// A zone and what can be booked in it.
class ZoneServices {
  final ArcadeExperience zone;
  final List<ServiceModel> services;

  const ZoneServices({required this.zone, required this.services});
}

/// Everything bookable, grouped by zone, and only zones that have something —
/// so the Book tab never shows a heading with nothing under it. The Sports Bar
/// and Rooftop Restro have no services.
final bookableServicesProvider =
    FutureProvider<List<ZoneServices>>((ref) async {
  final repo = ref.read(serviceRepositoryProvider);
  final found = await Future.wait(kArcadeExperiences.map((exp) async {
    final services = [
      for (final s in await repo.getServicesForExperience(exp.id))
        if (s.isBookable) s,
    ];
    return services.isEmpty ? null : ZoneServices(zone: exp, services: services);
  }));
  return found.nonNulls.toList();
});
