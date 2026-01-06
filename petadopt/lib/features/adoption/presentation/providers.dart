import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers.dart';
import '../../auth/presentation/providers.dart';
import '../data/datasources/adoption_remote_datasource.dart';
import '../data/repositories/adoption_repository_impl.dart';
import '../domain/entities/adoption_request.dart';
import '../domain/repositories/adoption_repository.dart';

final adoptionRepositoryProvider = Provider<AdoptionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AdoptionRepositoryImpl(remote: AdoptionRemoteDataSource(client), client: client);
});

final myAdoptionRequestsProvider = FutureProvider<List<AdoptionRequest>>((ref) async {
  final repo = ref.watch(adoptionRepositoryProvider);
  return repo.myRequests();
});

final shelterAdoptionRequestsProvider = FutureProvider<List<AdoptionRequest>>((ref) async {
  final repo = ref.watch(adoptionRepositoryProvider);
  return repo.shelterRequests();
});

final adoptionControllerProvider = StateNotifierProvider<AdoptionController, AsyncValue<void>>((ref) {
  final repo = ref.watch(adoptionRepositoryProvider);
  final uid = ref.watch(currentUserIdProvider);
  return AdoptionController(ref, repo, uid);
});

class AdoptionController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final AdoptionRepository repo;
  final String? uid;

  AdoptionController(this.ref, this.repo, this.uid) : super(const AsyncData(null));

  Future<void> create({required String petId, required String shelterId, required String message}) async {
    final adopterId = uid;
    if (adopterId == null) return;
    state = const AsyncLoading();
    try {
      await repo.createRequest(AdoptionRequest(
        id: const Uuid().v4(),
        petId: petId,
        adopterId: adopterId,
        shelterId: shelterId,
        status: 'pending',
        message: message,
      ));
      ref.invalidate(myAdoptionRequestsProvider);
      ref.invalidate(shelterAdoptionRequestsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setStatus({required String requestId, required String status, String? petIdIfApproved}) async {
    state = const AsyncLoading();
    try {
      await repo.updateStatus(requestId: requestId, status: status);
      if (status == 'approved' && petIdIfApproved != null) {
        await repo.markPetAdopted(petIdIfApproved);
      }
      ref.invalidate(myAdoptionRequestsProvider);
      ref.invalidate(shelterAdoptionRequestsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
