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
    super.adopterName,
    super.shelterName,
  });

  factory AdoptionRequestModel.fromMap(Map<String, dynamic> map) {
    final pet = map['pets'];
    final adopter = map['adopter'];
    final shelter = map['shelter'];

    return AdoptionRequestModel(
      id: map['id'] as String,
      petId: map['pet_id'] as String,
      adopterId: map['adopter_id'] as String,
      shelterId: map['shelter_id'] as String,
      status: (map['status'] ?? 'pending') as String,
      message: (map['message'] ?? '') as String,

      petName: pet is Map ? (pet['name'] as String?) : null,
      petBreed: pet is Map ? (pet['breed'] as String?) : null,
      petStatus: pet is Map ? (pet['status'] as String?) : null,

      adopterName: adopter is Map ? (adopter['full_name'] as String?) : null,
      shelterName: shelter is Map ? (shelter['full_name'] as String?) : null,
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
