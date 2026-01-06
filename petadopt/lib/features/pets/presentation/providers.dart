import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers.dart';
import '../../auth/presentation/providers.dart';
import '../data/datasources/pets_remote_datasource.dart';
import '../data/repositories/pets_repository_impl.dart';
import '../domain/entities/pet.dart';
import '../domain/repositories/pets_repository.dart';

final petsRepositoryProvider = Provider<PetsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PetsRepositoryImpl(remote: PetsRemoteDataSource(client), client: client);
});

final availablePetsQueryProvider = StateProvider<String>((ref) => '');

final availablePetsProvider = FutureProvider<List<Pet>>((ref) async {
  final repo = ref.watch(petsRepositoryProvider);
  final q = ref.watch(availablePetsQueryProvider);
  return repo.listAvailablePets(query: q);
});

final myPetsProvider = FutureProvider<List<Pet>>((ref) async {
  final repo = ref.watch(petsRepositoryProvider);
  return repo.listMyPets();
});

final petByIdProvider = FutureProvider.family<Pet?, String>((ref, id) async {
  final repo = ref.watch(petsRepositoryProvider);
  return repo.getPet(id);
});

final petsControllerProvider = StateNotifierProvider<PetsController, AsyncValue<void>>((ref) {
  final repo = ref.watch(petsRepositoryProvider);
  final uid = ref.watch(currentUserIdProvider);
  return PetsController(ref, repo, uid);
});

class PetsController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final PetsRepository repo;
  final String? uid;

  PetsController(this.ref, this.repo, this.uid) : super(const AsyncData(null));

  Future<void> createOrUpdate({
    String? id,
    required String name,
    required String species,
    required String breed,
    required int age,
    required String description,
    required String status,
    List<String> imagePaths = const [],
    int primaryIndex = 0,
  }) async {
    final shelterId = uid;
    if (shelterId == null) return;

    state = const AsyncLoading();
    try {
      final petId = id ?? const Uuid().v4();

      // Subir imágenes (máx 5) y obtener URLs públicas
      final urls = <String>[];
      final limited = imagePaths.take(5).toList();

      for (var i = 0; i < limited.length; i++) {
        final fileName = '${petId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final url = await repo.uploadPetImage(filePath: limited[i], fileName: fileName);
        urls.add(url);
      }

      final safePrimary = urls.isEmpty ? 0 : primaryIndex.clamp(0, urls.length - 1);

      // Upsert mascota (compatibilidad: photoUrl = principal)
      final primaryUrl = urls.isNotEmpty ? urls[safePrimary] : '';

      await repo.upsertPet(Pet(
        id: petId,
        shelterId: shelterId,
        name: name,
        species: species,
        breed: breed,
        age: age,
        description: description,
        photoUrl: primaryUrl,
        status: status,
      ));

      // Guardar fotos en tabla pet_photos (si hay)
      if (urls.isNotEmpty) {
        await repo.upsertPetPhotos(petId: petId, urls: urls, primaryIndex: safePrimary);
      }

      ref.invalidate(myPetsProvider);
      ref.invalidate(availablePetsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }


  Future<void> delete(String id) async {
    state = const AsyncLoading();
    try {
      await repo.deletePet(id);
      ref.invalidate(myPetsProvider);
      ref.invalidate(availablePetsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
