import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/utils/env.dart';
import '../providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _forgotPasswordDialog() async {
    final ctrl = TextEditingController(text: emailCtrl.text.trim());
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restablecer contraseña'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo',
                hintText: 'ejemplo@correo.com',
              ),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Ingresa tu correo';
                if (!s.contains('@')) return 'Correo inválido';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Enviar link'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      final email = ctrl.text.trim();
      await ref.read(authControllerProvider.notifier).sendPasswordReset(email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Revisa tu correo. El link abrirá la web auxiliar (/reset).'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (_, next) {
      next.whenOrNull(
        error: (e, __) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        ),
      );
    });

    return AppScaffold(
      title: 'PetAdopt',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Correo'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passCtrl,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                    ),
                  ),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: state is AsyncLoading ? null : _forgotPasswordDialog,
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),

                  const SizedBox(height: 6),

                  FilledButton(
                    onPressed: state is AsyncLoading
                        ? null
                        : () => ref.read(authControllerProvider.notifier).signIn(
                              emailCtrl.text.trim(),
                              passCtrl.text,
                            ),
                    child: state is AsyncLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),

                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/signup'),
                    child: const Text('Crear cuenta'),
                  ),

                  const SizedBox(height: 6),

                  if (Env.enableGoogleOAuth)
                    OutlinedButton.icon(
                      onPressed: state is AsyncLoading
                          ? null
                          : () => ref.read(authControllerProvider.notifier).signInGoogle(),
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Continuar con Google'),
                    ),

                  const SizedBox(height: 10),
                  const Text(
                    'Nota: La confirmación de cuenta y el reset se gestionan por link enviado al correo 😺🐶.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
