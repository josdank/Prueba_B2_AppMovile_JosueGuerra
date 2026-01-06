import 'pet_photo.dart';

class Pet {
  final String id;
  final String shelterId;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String description;

  /// Foto principal (compatibilidad con versión anterior)
  final String photoUrl;

  /// Lista de fotos (hasta 5)
  final List<PetPhoto> photos;

  final String status; // available / adopted

  const Pet({
    required this.id,
    required this.shelterId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.description,
    required this.photoUrl,
    this.photos = const [],
    required this.status,
  });

  bool get isAvailable => status == 'available';

  String get primaryPhoto => photos.firstWhere(
        (p) => p.isPrimary,
        orElse: () => photos.isNotEmpty
            ? photos.first
            : PetPhoto(id: '', petId: id, url: photoUrl, isPrimary: true, sortOrder: 0),
      ).url;
}
