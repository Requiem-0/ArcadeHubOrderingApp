// lib/features/auth/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool isEmailVerified;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.isEmailVerified = false,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['username']?.toString() ?? 'Customer',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      isEmailVerified: json['isEmailVerified'] == true,
      isActive: json['isActive'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'isEmailVerified': isEmailVerified,
        'isActive': isActive,
      };
}
