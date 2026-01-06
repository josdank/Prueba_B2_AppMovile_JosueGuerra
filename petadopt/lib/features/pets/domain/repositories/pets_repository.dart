import '../entities/pet.dart';

abstract class PetsRepository {
  Future<List<Pet>> listAvailablePets({String? query});
  Future<List<Pet>> listMyPets();
  Future<Pet?> getPet(String id);

  Future<void> upsertPet(Pet pet);
  Future<void> upsertPetPhotos({
    required String petId,
    required List<String> urls,
    required int primaryIndex,
  });

  Future<void> deletePet(String id);

  Future<String> uploadPetImage({required String filePath, required String fileName});
}
