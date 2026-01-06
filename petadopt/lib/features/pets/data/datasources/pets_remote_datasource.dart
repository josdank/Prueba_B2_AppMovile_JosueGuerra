import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_model.dart';

class PetsRemoteDataSource {
  final SupabaseClient client;
  PetsRemoteDataSource(this.client);

  Future<List<PetModel>> listAvailablePets({String? query}) async {
    final data = await client
        .from('pets')
        .select('*, pet_photos(*)')
        .eq('status', 'available')
        .order('created_at', ascending: false);

    final list = (data as List)
        .map((e) => PetModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    if (query == null || query.trim().isEmpty) return list;

    final q = query.toLowerCase();
    return list
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.breed.toLowerCase().contains(q) ||
            p.species.toLowerCase().contains(q))
        .toList();
  }

  Future<List<PetModel>> listMyPets(String shelterId) async {
    final data = await client
        .from('pets')
        .select('*, pet_photos(*)')
        .eq('shelter_id', shelterId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => PetModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<PetModel?> getPet(String id) async {
    final data = await client
        .from('pets')
        .select('*, pet_photos(*)')
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return PetModel.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> upsertPet(PetModel pet) async {
    await client.from('pets').upsert(pet.toInsertMap());
  }

  Future<void> upsertPetPhotos({
    required String petId,
    required List<String> urls,
    required int primaryIndex,
  }) async {
    // 1) borrar fotos anteriores
    await client.from('pet_photos').delete().eq('pet_id', petId);

    // 2) insertar nuevas
    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < urls.length; i++) {
      rows.add({
        'pet_id': petId,
        'url': urls[i],
        'is_primary': i == primaryIndex,
        'sort_order': i,
      });
    }
    if (rows.isNotEmpty) {
      await client.from('pet_photos').insert(rows);
    }

    // 3) mantener compatibilidad: actualizar photo_url (principal)
    if (urls.isNotEmpty) {
      await client.from('pets').update({'photo_url': urls[primaryIndex]}).eq('id', petId);
    }
  }

  Future<void> deletePet(String id) async {
    await client.from('pets').delete().eq('id', id);
  }

  Future<String> uploadPetImage({
    required String filePath,
    required String fileName,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final path = 'pets/$fileName';
    await client.storage
        .from('pet-images')
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return client.storage.from('pet-images').getPublicUrl(path);
  }
}
