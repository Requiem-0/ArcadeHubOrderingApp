// lib/features/address/location_model.dart

class LocationModel {
  final String id;
  final String title;
  final String address;
  final String? note;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  const LocationModel({
    required this.id,
    required this.title,
    required this.address,
    this.note,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Address',
      address: json['address']?.toString() ?? '',
      note: json['note']?.toString(),
      isDefault: json['isDefault'] == true,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'address': address,
        'note': note,
        'isDefault': isDefault,
        'latitude': latitude,
        'longitude': longitude,
      };
}
