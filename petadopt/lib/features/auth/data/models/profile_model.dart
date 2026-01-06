import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.phone,
    required super.role,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      fullName: (map['full_name'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      role: (map['role'] ?? '') as String,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'role': role,
    };
  }
}
