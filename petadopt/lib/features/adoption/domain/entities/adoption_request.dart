class AdoptionRequest {
  final String id;
  final String petId;
  final String adopterId;
  final String shelterId;
  final String status; // pending/approved/rejected
  final String message;

  // Extras para UI (join con pets)
  final String? petName;
  final String? petBreed;
  final String? petStatus;

  const AdoptionRequest({
    required this.id,
    required this.petId,
    required this.adopterId,
    required this.shelterId,
    required this.status,
    required this.message,
    this.petName,
    this.petBreed,
    this.petStatus,
  });

  bool get isPending => status == 'pending';
}
