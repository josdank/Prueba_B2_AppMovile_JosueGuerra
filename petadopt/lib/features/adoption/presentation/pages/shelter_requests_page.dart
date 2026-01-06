import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../providers.dart';

class ShelterRequestsPage extends ConsumerWidget {
  const ShelterRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reqAsync = ref.watch(shelterAdoptionRequestsProvider);
    final ctrlState = ref.watch(adoptionControllerProvider);

    ref.listen(adoptionControllerProvider, (_, next) {
      next.whenOrNull(
        error: (e, __) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))),
      );
    });

    return AppScaffold(
      title: 'Solicitudes (Refugio)',
      body: reqAsync.when(
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No hay solicitudes.'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final r = items[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.assignment),
                    title: Text('Solicitud ${r.id.substring(0, 6)} • ${r.status}'),
                    subtitle: Text(
                      'Pet: ${r.petId}\n'
                      'Adopter: ${r.adopterId}\n'
                      '${r.message}',
                    ),
                    trailing: r.isPending
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Aprobar',
                                onPressed: ctrlState is AsyncLoading
                                    ? null
                                    : () => ref.read(adoptionControllerProvider.notifier).setStatus(
                                          requestId: r.id,
                                          status: 'approved',
                                          petIdIfApproved: r.petId,
                                        ),
                                icon: const Icon(Icons.check_circle_outline),
                              ),
                              IconButton(
                                tooltip: 'Rechazar',
                                onPressed: ctrlState is AsyncLoading
                                    ? null
                                    : () => ref.read(adoptionControllerProvider.notifier).setStatus(
                                          requestId: r.id,
                                          status: 'rejected',
                                        ),
                                icon: const Icon(Icons.cancel_outlined),
                              ),
                            ],
                          )
                        : null,
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
