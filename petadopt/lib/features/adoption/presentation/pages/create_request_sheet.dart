import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class CreateRequestSheet extends ConsumerStatefulWidget {
  final String petId;
  final String shelterId;
  const CreateRequestSheet({super.key, required this.petId, required this.shelterId});

  @override
  ConsumerState<CreateRequestSheet> createState() => _CreateRequestSheetState();
}

class _CreateRequestSheetState extends ConsumerState<CreateRequestSheet> {
  final msgCtrl = TextEditingController();

  @override
  void dispose() {
    msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adoptionControllerProvider);

    ref.listen(adoptionControllerProvider, (_, next) {
      next.whenOrNull(
        data: (_) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada')));
        },
        error: (e, __) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))),
      );
    });

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Solicitud de adopción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          TextField(
            controller: msgCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Mensaje',
              hintText: 'Ej: Tengo experiencia cuidando mascotas, vivo cerca, puedo cubrir vacunas...',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state is AsyncLoading
                ? null
                : () => ref.read(adoptionControllerProvider.notifier).create(
                      petId: widget.petId,
                      shelterId: widget.shelterId,
                      message: msgCtrl.text.trim(),
                    ),
            child: state is AsyncLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
