import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../providers.dart';

class MyRequestsPage extends ConsumerWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reqAsync = ref.watch(myAdoptionRequestsProvider);

    return AppScaffold(
      title: 'Mis solicitudes',
      body: reqAsync.when(
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No has enviado solicitudes.'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final r = items[i];

              final petName = (r.petName ?? '').trim().isNotEmpty ? r.petName!.trim() : r.petId;
              final petBreed = (r.petBreed ?? '').trim();
              final petStatus = (r.petStatus ?? '').trim();

              final shelterName =
                  (r.shelterName ?? '').trim().isNotEmpty ? r.shelterName!.trim() : r.shelterId;

              final msg = r.message.trim().isEmpty ? 'Sin mensaje.' : r.message.trim();

              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.pets),
                    title: Text('$petName • ${r.status}'),
                    subtitle: Text(
                      'Raza: ${petBreed.isEmpty ? 'N/A' : petBreed}'
                      'Refugio: $shelterName'
                      '${petStatus.isEmpty ? '' : 'Estado mascota: $petStatus\n'}'
                      'Mensaje: $msg',
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
