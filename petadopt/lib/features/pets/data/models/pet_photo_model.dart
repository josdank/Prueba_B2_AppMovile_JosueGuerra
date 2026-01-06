import '../../domain/entities/pet_photo.dart';

class PetPhotoModel extends PetPhoto {
  const PetPhotoModel({
    required super.id,
    required super.petId,
    required super.url,
    required super.isPrimary,
    required super.sortOrder,
  });

  factory PetPhotoModel.fromMap(Map<String, dynamic> map) {
    return PetPhotoModel(
      id: (map['id'] ?? '').toString(),
      petId: (map['pet_id'] ?? '').toString(),
      url: (map['url'] ?? '').toString(),
      isPrimary: (map['is_primary'] ?? false) as bool,
      sortOrder: (map['sort_order'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'pet_id': petId,
        'url': url,
        'is_primary': isPrimary,
        'sort_order': sortOrder,
      };
}
