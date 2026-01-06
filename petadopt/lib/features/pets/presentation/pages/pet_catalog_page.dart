import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_scaffold.dart';
import 'package:petadopt/features/auth/presentation/providers.dart';
import '../providers.dart';
import '../widgets/pet_card.dart';

class PetCatalogPage extends ConsumerWidget {
  const PetCatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(availablePetsProvider);
    final profileAsync = ref.watch(myProfileProvider);

    return AppScaffold(
      title: 'Mascotas disponibles',
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
        ),
      ],
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Buscar por nombre, especie o raza',
            ),
            onChanged: (v) => ref.read(availablePetsQueryProvider.notifier).state = v,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: petsAsync.when(
              data: (pets) {
                if (pets.isEmpty) {
                  return const Center(child: Text('No hay mascotas disponibles por ahora.'));
                }
                return ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (_, i) => PetCard(
                    pet: pets[i],
                    onTap: () => Navigator.of(context).pushNamed('/pet', arguments: pets[i].id),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          profileAsync.when(
            data: (p) => p == null ? const SizedBox.shrink() : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
