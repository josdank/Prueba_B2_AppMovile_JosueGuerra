class AdoptionRequest {
  final String id;
  final String petId;
  final String adopterId;
  final String shelterId;
  final String status; // pending/approved/rejected
  final String message;

  // Extra display fields (opcionales)
  final String? petName;
  final String? petBreed;
  final String? petStatus;
  final String? adopterName;
  final String? shelterName;

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
    this.adopterName,
    this.shelterName,
  });

  bool get isPending => status == 'pending';
}
