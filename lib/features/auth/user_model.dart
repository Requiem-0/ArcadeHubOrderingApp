// lib/features/auth/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? role;
  final String? image;
  final bool isEmailVerified;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.role,
    this.image,
    this.isEmailVerified = false,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          json['userId']?.toString() ??
          '',
      name: json['name']?.toString() ??
          json['customerName']?.toString() ??
          json['username']?.toString() ??
          'Customer',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      address: json['address']?.toString(),
      role: json['role']?.toString(),
      image: json['image']?.toString(),
      isEmailVerified: json['isEmailVerified'] == true,
      isActive: json['isActive'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (role != null) 'role': role,
        if (image != null) 'image': image,
        'isEmailVerified': isEmailVerified,
        'isActive': isActive,
      };
}

