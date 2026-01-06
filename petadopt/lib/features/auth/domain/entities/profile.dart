class Profile {
  final String id;
  final String fullName;
  final String phone;
  final String role; // 'adopter' | 'shelter'

  const Profile({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
  });

  bool get isShelter => role == 'shelter';
  bool get isAdopter => role == 'adopter';
}
