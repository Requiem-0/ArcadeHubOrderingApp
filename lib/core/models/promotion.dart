class PromotionModel {
  final String id;
  final String title;
  final String description;
  final double? discountPercentage;
  final String? timeRestriction;

  const PromotionModel({
    required this.id,
    required this.title,
    required this.description,
    this.discountPercentage,
    this.timeRestriction,
  });
}
