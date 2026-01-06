class PetPhoto {
  final String id;
  final String petId;
  final String url;
  final bool isPrimary;
  final int sortOrder;

  const PetPhoto({
    required this.id,
    required this.petId,
    required this.url,
    required this.isPrimary,
    required this.sortOrder,
  });
}
