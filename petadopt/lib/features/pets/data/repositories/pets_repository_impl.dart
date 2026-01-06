import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/pet.dart';
import '../../domain/repositories/pets_repository.dart';
import '../datasources/pets_remote_datasource.dart';
import '../models/pet_model.dart';

class PetsRepositoryImpl implements PetsRepository {
  final PetsRemoteDataSource remote;
  final SupabaseClient client;

  PetsRepositoryImpl({required this.remote, required this.client});

  String? get _uid => client.auth.currentUser?.id;

  @override
  Future<List<Pet>> listAvailablePets({String? query}) =>
      remote.listAvailablePets(query: query);

  @override
  Future<List<Pet>> listMyPets() async {
    final uid = _uid;
    if (uid == null) return [];
    return remote.listMyPets(uid);
  }

  @override
  Future<Pet?> getPet(String id) => remote.getPet(id);

  @override
  Future<void> upsertPet(Pet pet) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');

    final model = PetModel(
      id: pet.id,
      shelterId: uid,
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      age: pet.age,
      description: pet.description,
      photoUrl: pet.photoUrl,
      photos: pet.photos,
      status: pet.status,
    );
    await remote.upsertPet(model);
  }

  @override
  Future<void> upsertPetPhotos({
    required String petId,
    required List<String> urls,
    required int primaryIndex,
  }) =>
      remote.upsertPetPhotos(petId: petId, urls: urls, primaryIndex: primaryIndex);

  @override
  Future<void> deletePet(String id) => remote.deletePet(id);

  @override
  Future<String> uploadPetImage({required String filePath, required String fileName}) =>
      remote.uploadPetImage(filePath: filePath, fileName: fileName);
}
