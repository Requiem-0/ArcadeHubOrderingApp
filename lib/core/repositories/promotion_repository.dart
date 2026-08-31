import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/promotion.dart';

class PromotionRepository {
  Future<PromotionModel?> getActivePromotion() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    // For now, this is nullable to simulate that the business might not have configured a promo.
    // We return null to ensure the frontend doesn't hardcode discount logic.
    return null; 
    
    /* Example of a configured promotion from the backend:
    return const PromotionModel(
      id: 'promo-1',
      title: 'App Order Discount',
      description: 'Order via the app and get a discount on all food & drinks.',
      discountPercentage: 10.0,
      timeRestriction: '5:00 PM - 8:00 PM',
    );
    */
  }
}

final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  return PromotionRepository();
});

final activePromotionProvider = FutureProvider<PromotionModel?>((ref) async {
  return ref.read(promotionRepositoryProvider).getActivePromotion();
});
