import 'package:flutter/material.dart';

import '../pets/presentation/pages/my_pets_page.dart';
import '../adoption/presentation/pages/shelter_requests_page.dart';
import '../profile/presentation/profile_page.dart';

class ShelterShell extends StatefulWidget {
  const ShelterShell({super.key});

  @override
  State<ShelterShell> createState() => _ShelterShellState();
}

class _ShelterShellState extends State<ShelterShell> {
  int index = 0;

  final pages = const [
    MyPetsPage(),
    ShelterRequestsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: 'Mascotas'),
          NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox), label: 'Solicitudes'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
