class ServiceModel {
  final String id;
  final String experienceId;
  final String name;
  final String description;
  final double? price;
  final String? durationText;
  final String? rules;
  final bool isBookable;

  /// The photo shown on the Book tab. Placeholder stock until the venue sends
  /// its own; null falls back to the zone's icon.
  final String? imageUrl;

  const ServiceModel({
    required this.id,
    required this.experienceId,
    required this.name,
    required this.description,
    this.price,
    this.durationText,
    this.rules,
    this.isBookable = false,
    this.imageUrl,
  });
}
