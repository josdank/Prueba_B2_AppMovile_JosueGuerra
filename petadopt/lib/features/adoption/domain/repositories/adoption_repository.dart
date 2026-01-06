import '../entities/adoption_request.dart';

abstract class AdoptionRepository {
  Future<void> createRequest(AdoptionRequest req);
  Future<List<AdoptionRequest>> myRequests();
  Future<List<AdoptionRequest>> shelterRequests();
  Future<void> updateStatus({required String requestId, required String status});
  Future<void> markPetAdopted(String petId);
}
