import '../../domain/entities/pet.dart';
import 'pet_photo_model.dart';

class PetModel extends Pet {
  const PetModel({
    required super.id,
    required super.shelterId,
    required super.name,
    required super.species,
    required super.breed,
    required super.age,
    required super.description,
    required super.photoUrl,
    super.photos = const [],
    required super.status,
  });

  factory PetModel.fromMap(Map<String, dynamic> map) {
    final photosRaw = map['pet_photos'] as List?;
    final photos = photosRaw == null
        ? <PetPhotoModel>[]
        : photosRaw
            .map((e) => PetPhotoModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList()
          ..sort((a, b) {
            if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
            return a.sortOrder.compareTo(b.sortOrder);
          });

    final primaryFromPhotos = photos.isNotEmpty
        ? photos.firstWhere((p) => p.isPrimary, orElse: () => photos.first).url
        : null;

    return PetModel(
      id: (map['id'] ?? '').toString(),
      shelterId: (map['shelter_id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      species: (map['species'] ?? '').toString(),
      breed: (map['breed'] ?? '').toString(),
      age: (map['age'] ?? 0) as int,
      description: (map['description'] ?? '').toString(),
      photoUrl: (primaryFromPhotos ?? map['photo_url'] ?? '').toString(),
      photos: photos,
      status: (map['status'] ?? 'available').toString(),
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'id': id,
        'shelter_id': shelterId,
        'name': name,
        'species': species,
        'breed': breed,
        'age': age,
        'description': description,
        'photo_url': photoUrl,
        'status': status,
      };
}
