import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../adoption/presentation/pages/create_request_sheet.dart';
import '../providers.dart';

class PetDetailPage extends ConsumerWidget {
  final String petId;
  const PetDetailPage({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsync = ref.watch(petByIdProvider(petId));

    return AppScaffold(
      title: 'Detalle',
      body: petAsync.when(
        data: (pet) {
          if (pet == null) return const Center(child: Text('Mascota no encontrada'));
          return ListView(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: pet.photoUrl.isEmpty
                      ? Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.pets, size: 70),
                        )
                      : CachedNetworkImage(imageUrl: pet.photoUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),
              Text(pet.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('${pet.species} • ${pet.breed} • ${pet.age} años'),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(pet.description.isEmpty ? 'Sin descripción.' : pet.description),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: pet.isAvailable
                    ? () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => CreateRequestSheet(petId: pet.id, shelterId: pet.shelterId),
                        )
                    : null,
                icon: const Icon(Icons.favorite),
                label: Text(pet.isAvailable ? 'Solicitar adopción' : 'Ya adoptado'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
