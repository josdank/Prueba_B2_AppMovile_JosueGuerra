import '../../domain/entities/adoption_request.dart';

class AdoptionRequestModel extends AdoptionRequest {
  const AdoptionRequestModel({
    required super.id,
    required super.petId,
    required super.adopterId,
    required super.shelterId,
    required super.status,
    required super.message,
    super.petName,
    super.petBreed,
    super.petStatus,
  });

  factory AdoptionRequestModel.fromMap(Map<String, dynamic> map) {
    final pet = map['pet'];
    String? name;
    String? breed;
    String? pStatus;

    if (pet is Map<String, dynamic>) {
      name = pet['name']?.toString();
      breed = pet['breed']?.toString();
      pStatus = pet['status']?.toString();
    } else if (pet is List && pet.isNotEmpty && pet.first is Map<String, dynamic>) {
      final p = Map<String, dynamic>.from(pet.first as Map);
      name = p['name']?.toString();
      breed = p['breed']?.toString();
      pStatus = p['status']?.toString();
    }

    return AdoptionRequestModel(
      id: map['id'] as String,
      petId: map['pet_id'] as String,
      adopterId: map['adopter_id'] as String,
      shelterId: map['shelter_id'] as String,
      status: (map['status'] ?? 'pending') as String,
      message: (map['message'] ?? '') as String,
      petName: name,
      petBreed: breed,
      petStatus: pStatus,
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'id': id,
        'pet_id': petId,
        'adopter_id': adopterId,
        'shelter_id': shelterId,
        'status': status,
        'message': message,
      };
}
