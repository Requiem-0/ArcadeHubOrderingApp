class ServiceModel {
  final String id;
  final String experienceId;
  final String name;
  final String description;
  final double? price;
  final String? durationText;
  final String? rules;
  final bool isBookable;

  const ServiceModel({
    required this.id,
    required this.experienceId,
    required this.name,
    required this.description,
    this.price,
    this.durationText,
    this.rules,
    this.isBookable = false,
  });
}
