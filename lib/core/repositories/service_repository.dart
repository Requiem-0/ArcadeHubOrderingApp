import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service.dart';

class ServiceRepository {
  Future<List<ServiceModel>> getServicesForExperience(String experienceId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 600));

    // This data would eventually come from the backend.
    final allServices = [
      const ServiceModel(
        id: 'srv-ps5',
        experienceId: 'playroom',
        name: 'PS5 Console Rental',
        description: 'Overnight gaming pass with up to 4 controllers.',
        price: 2000.0,
        durationText: '9:00 PM → 9:00 AM',
        rules: 'Late returns incur an additional hourly charge. Subject to availability.',
        isBookable: true,
      ),
      const ServiceModel(
        id: 'srv-vr',
        experienceId: 'playroom',
        name: 'VR Battle Arena',
        description: '30-minute immersive virtual reality session.',
        price: 500.0,
        durationText: '30 mins',
        isBookable: true,
      ),
      const ServiceModel(
        id: 'srv-ps5-area51',
        experienceId: 'area51',
        name: 'VIP PS5 Station',
        description: 'Private PS5 gaming in the futuristic lounge.',
        price: 2500.0,
        durationText: '9:00 PM → 9:00 AM',
        isBookable: true,
      ),
      const ServiceModel(
        id: 'srv-party',
        experienceId: 'partyroom',
        name: 'Private Room Booking',
        description: 'Exclusive use of the party room for celebrations.',
        durationText: 'Per Hour or Full Night',
        isBookable: true,
      ),
    ];

    return allServices.where((s) => s.experienceId == experienceId).toList();
  }
}

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
});

final servicesProvider = FutureProvider.family<List<ServiceModel>, String>((ref, experienceId) async {
  return ref.read(serviceRepositoryProvider).getServicesForExperience(experienceId);
});
