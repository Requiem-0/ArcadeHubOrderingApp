import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../brandkit/experiences.dart';
import '../models/service.dart';

class ServiceRepository {
  // This data would eventually come from the backend.
  static const List<ServiceModel> _all = [
    ServiceModel(
      id: 'srv-ps5',
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
      experienceId: 'playroom',
      name: 'VR Battle Arena',
      description: '30-minute immersive virtual reality session.',
      price: 500.0,
      durationText: '30 mins',
      isBookable: true,
    ),
    ServiceModel(
      id: 'srv-ps5-area51',
      experienceId: 'area51',
      name: 'VIP PS5 Station',
      description: 'Private PS5 gaming in the futuristic lounge.',
      price: 2500.0,
      durationText: '9:00 PM → 9:00 AM',
      isBookable: true,
    ),
    ServiceModel(
      id: 'srv-party',
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

/// Zones that actually have something to book, so the Book tab never offers a
/// zone that dead-ends. The Sports Bar and Rooftop Restro have no services.
final bookableZonesProvider = FutureProvider<List<ArcadeExperience>>((ref) async {
  final repo = ref.read(serviceRepositoryProvider);
  final found = await Future.wait(kArcadeExperiences.map((exp) async {
    final services = await repo.getServicesForExperience(exp.id);
    return services.any((s) => s.isBookable) ? exp : null;
  }));
  return found.nonNulls.toList();
});
