import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../providers.dart';

class MyRequestsPage extends ConsumerWidget {
  const MyRequestsPage({super.key});

  String _labelStatus(String s) {
    switch (s) {
      case 'approved':
        return 'Aprobada';
      case 'rejected':
        return 'Rechazada';
      default:
        return 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reqAsync = ref.watch(myAdoptionRequestsProvider);

    return AppScaffold(
      title: 'Mis solicitudes',
      body: reqAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Aún no tienes solicitudes.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final r = items[i];
              final petName = r.petName ?? 'Mascota';
              final breed = (r.petBreed ?? '').trim();
              final petStatus = (r.petStatus ?? '').trim();
              final subtitle = <String>[
                if (breed.isNotEmpty) 'Raza: $breed',
                if (petStatus.isNotEmpty) 'Estado mascota: $petStatus',
                'Solicitud: ${_labelStatus(r.status)}',
                if (r.message.trim().isNotEmpty) 'Mensaje: ${r.message.trim()}',
              ].join('\n');

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.pets),
                  title: Text(petName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(subtitle),
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
