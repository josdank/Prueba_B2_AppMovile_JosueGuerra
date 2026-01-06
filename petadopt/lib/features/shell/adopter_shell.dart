import 'package:flutter/material.dart';

import '../pets/presentation/pages/pet_catalog_page.dart';
import '../map/presentation/map_page.dart';
import '../chat_ai/presentation/chat_page.dart';
import '../adoption/presentation/pages/my_requests_page.dart';
import '../profile/presentation/profile_page.dart';

class AdopterShell extends StatefulWidget {
  const AdopterShell({super.key});

  @override
  State<AdopterShell> createState() => _AdopterShellState();
}

class _AdopterShellState extends State<AdopterShell> {
  int index = 0;

  final pages = const [
    PetCatalogPage(),
    MapPage(),
    ChatPage(),
    MyRequestsPage(),
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
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy), label: 'Chat IA'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Solicitudes'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
