import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/adoption_request.dart';
import '../../domain/repositories/adoption_repository.dart';
import '../datasources/adoption_remote_datasource.dart';
import '../models/adoption_request_model.dart';

class AdoptionRepositoryImpl implements AdoptionRepository {
  final AdoptionRemoteDataSource remote;
  final SupabaseClient client;

  AdoptionRepositoryImpl({required this.remote, required this.client});

  String? get _uid => client.auth.currentUser?.id;

  @override
  Future<void> createRequest(AdoptionRequest req) async {
    await remote.createRequest(AdoptionRequestModel(
      id: req.id,
      petId: req.petId,
      adopterId: req.adopterId,
      shelterId: req.shelterId,
      status: req.status,
      message: req.message,
    ));
  }

  @override
  Future<List<AdoptionRequest>> myRequests() async {
    final uid = _uid;
    if (uid == null) return [];
    return remote.myRequests(uid);
  }

  @override
  Future<List<AdoptionRequest>> shelterRequests() async {
    final uid = _uid;
    if (uid == null) return [];
    return remote.shelterRequests(uid);
  }

  @override
  Future<void> updateStatus({required String requestId, required String status}) {
    return remote.updateStatus(id: requestId, status: status);
  }

  @override
  Future<void> markPetAdopted(String petId) => remote.markPetAdopted(petId);
}
