import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/env.dart';

import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/presentation/pages/complete_profile_page.dart';
import 'features/auth/presentation/providers.dart' as auth;

import 'features/pets/presentation/pages/pet_catalog_page.dart';
import 'features/pets/presentation/pages/my_pets_page.dart';
import 'features/pets/presentation/pages/pet_detail_page.dart';
import 'features/pets/presentation/pages/pet_form_page.dart';

import 'features/chat_ai/presentation/chat_page.dart';
import 'features/map/presentation/map_page.dart';

import 'features/adoption/presentation/pages/my_requests_page.dart';
import 'features/adoption/presentation/pages/shelter_requests_page.dart';
import 'features/shell/adopter_shell.dart';
import 'features/shell/shelter_shell.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  if (Env.enableFirebase) {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // Si falta google-services.json o configuración, la app igual puede correr sin push.
    }
  }

  runApp(const ProviderScope(child: PetAdoptApp()));
}

class PetAdoptApp extends ConsumerWidget {
  const PetAdoptApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'PetAdopt',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        switch (name) {
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpPage());
          case '/complete-profile':
            return MaterialPageRoute(builder: (_) => const CompleteProfilePage());
          case '/adopter-home':
            return MaterialPageRoute(builder: (_) => const PetCatalogPage());
          case '/shelter-home':
            return MaterialPageRoute(builder: (_) => const MyPetsPage());
          case '/pet':
            final id = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => PetDetailPage(petId: id));
          case '/pet-form':
            final id = settings.arguments as String?;
            return MaterialPageRoute(builder: (_) => PetFormPage(petId: id));
          case '/chat':
            return MaterialPageRoute(builder: (_) => const ChatPage());
          case '/map':
            return MaterialPageRoute(builder: (_) => const MapPage());
          case '/my-requests':
            return MaterialPageRoute(builder: (_) => const MyRequestsPage());
          case '/shelter-requests':
            return MaterialPageRoute(builder: (_) => const ShelterRequestsPage());
          default:
            return MaterialPageRoute(builder: (_) => const AppGate());
        }
      },
      home: const AppGate(),
    );
  }
}

/// Decide la pantalla inicial según: sesión -> perfil -> rol
class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    if (session == null) {
      return const LoginPage();
    }

    final profileAsync = ref.watch(auth.myProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error perfil: $e'))),
      data: (profile) {
        // Si no existe perfil, completar
        if (profile == null || profile.role.isEmpty) {
          return const CompleteProfilePage();
        }

        //  Shell con bottom navigation (similar al mock, colores diferentes)
        if (profile.role == 'shelter') {
          return const ShelterShell();
        }
        return const AdopterShell();
      },
    );
  }
}
