import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_scaffold.dart';
import 'package:petadopt/features/auth/presentation/providers.dart';
import '../providers.dart';
import '../widgets/pet_card.dart';

class MyPetsPage extends ConsumerWidget {
  const MyPetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(myPetsProvider);

    return AppScaffold(
      title: 'Mis mascotas (Refugio)',
      actions: [
        IconButton(
          icon: const Icon(Icons.assignment_outlined),
          onPressed: () => Navigator.of(context).pushNamed('/shelter-requests'),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/pet-form'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: petsAsync.when(
        data: (pets) {
          if (pets.isEmpty) return const Center(child: Text('Todavía no hay mascotas publicadas.'));
          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (_, i) => PetCard(
              pet: pets[i],
              onTap: () => Navigator.of(context).pushNamed('/pet-form', arguments: pets[i].id),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => ref.read(petsControllerProvider.notifier).delete(pets[i].id),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
