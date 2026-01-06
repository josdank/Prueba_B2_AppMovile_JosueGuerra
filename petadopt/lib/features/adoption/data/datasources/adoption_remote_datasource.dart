import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/adoption_request_model.dart';

class AdoptionRemoteDataSource {
  final SupabaseClient client;
  AdoptionRemoteDataSource(this.client);

  /// Inserción segura por RPC (evita RLS insert en adoption_requests)
  Future<void> createRequest(AdoptionRequestModel req) async {
    await client.rpc('create_adoption_request', params: {
      'p_pet_id': req.petId,
      'p_message': req.message,
    });
  }

  /// Solicitudes del adoptante logueado + info de mascota + nombre del refugio
  Future<List<AdoptionRequestModel>> myRequests(String uid) async {
    final data = await client
        .from('adoption_requests')
        .select(
          'id, pet_id, adopter_id, shelter_id, status, message, created_at, '
          'pets(name, breed, status), '
          'shelter:profiles!shelter_id(full_name)'
        )
        .eq('adopter_id', uid)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => AdoptionRequestModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Solicitudes del refugio logueado + info de mascota + nombre del adoptante
  Future<List<AdoptionRequestModel>> shelterRequests(String uid) async {
    final data = await client
        .from('adoption_requests')
        .select(
          'id, pet_id, adopter_id, shelter_id, status, message, created_at, '
          'pets(name, breed, status), '
          'adopter:profiles!adopter_id(full_name)'
        )
        .eq('shelter_id', uid)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => AdoptionRequestModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> updateStatus({required String id, required String status}) async {
    await client.from('adoption_requests').update({'status': status}).eq('id', id);
  }

  Future<void> markPetAdopted(String petId) async {
    await client.from('pets').update({'status': 'adopted'}).eq('id', petId);
  }
}
