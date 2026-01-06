import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../providers.dart';

class CompleteProfilePage extends ConsumerStatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  ConsumerState<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends ConsumerState<CompleteProfilePage> {
  final fullNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  String role = 'adopter'; // adopter | shelter
  bool saving = false;

  @override
  void dispose() {
    fullNameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final fullName = fullNameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu nombre completo.')),
      );
      return;
    }

    if (phone.isEmpty || phone.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un teléfono válido.')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await ref.read(authControllerProvider.notifier).saveProfile(
            fullName: fullName,
            phone: phone,
            role: role,
          );

      if (!mounted) return;

      // ✅ fuerza refresh del perfil
      ref.invalidate(myProfileProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Perfil guardado correctamente.')),
      );
      // 👉 ya no navegamos aquí, dejamos que el listener decida
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el perfil. Revisa tu conexión e inténtalo.')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔎 Listener que observa cambios en el perfil
    ref.listen(myProfileProvider, (previous, next) {
      final profile = next.valueOrNull;
      if (profile == null) return;

      // ✅ Redirige según rol
      if (profile.role == 'adopter') {
        Navigator.of(context).pushNamedAndRemoveUntil('/adopterHome', (r) => false);
      } else if (profile.role == 'shelter') {
        Navigator.of(context).pushNamedAndRemoveUntil('/shelterHome', (r) => false);
      }
    });

    return AppScaffold(
      title: 'Completar perfil',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Último paso',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: fullNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        hintText: 'Ej: Josue Guerra',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        hintText: 'Ej: 0999999999',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selector rol tipo mock
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.black.withOpacity(.08)),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _RoleButton(
                              selected: role == 'adopter',
                              icon: Icons.favorite,
                              label: 'Adoptante',
                              onTap: saving ? null : () => setState(() => role = 'adopter'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _RoleButton(
                              selected: role == 'shelter',
                              icon: Icons.home_work_rounded,
                              label: 'Refugio',
                              onTap: saving ? null : () => setState(() => role = 'shelter'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: 180,
                      child: FilledButton(
                        onPressed: saving ? null : _save,
                        child: saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Guardar'),
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text(
                      'Roles: Adoptante (ver y solicitar) / Refugio (publicar mascotas y gestionar solicitudes).',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _RoleButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Theme.of(context).colorScheme.primary.withOpacity(.10) : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Theme.of(context).colorScheme.primary : Colors.black54),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected ? Theme.of(context).colorScheme.primary : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
