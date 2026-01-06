import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../auth/presentation/providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  bool initialized = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);

    return profileAsync.when(
      loading: () => const AppScaffold(title: 'Perfil', body: Center(child: CircularProgressIndicator())),
      error: (e, _) => AppScaffold(title: 'Perfil', body: Center(child: Text('Error: $e'))),
      data: (p) {
        if (!initialized) {
          nameCtrl.text = p?.fullName ?? '';
          phoneCtrl.text = p?.phone ?? '';
          initialized = true;
        }

        final roleLabel = (p?.role ?? '') == 'shelter' ? 'Refugio' : 'Adoptante';

        return AppScaffold(
          title: 'Perfil',
          actions: [
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            )
          ],
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            child: Text((p?.fullName ?? 'U').trim().isEmpty ? 'U' : (p!.fullName.trim()[0]).toUpperCase()),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p?.fullName ?? 'Usuario', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text('Rol: $roleLabel', style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre completo'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Teléfono'),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          final phone = phoneCtrl.text.trim();
                          if (name.isEmpty || phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa nombre y teléfono')));
                            return;
                          }
                          await ref.read(authControllerProvider.notifier).saveProfile(
                                fullName: name,
                                phone: phone,
                                role: p?.role ?? 'adopter',
                              );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar cambios'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
