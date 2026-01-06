import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/env.dart';
import '../../../core/widgets/app_scaffold.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? pos;
  String? error;
  String? selectedId;

  final Distance _distance = const Distance();

  List<Map<String, dynamic>> get refugios => [
        {'id': 'A', 'name': Env.shelterAName, 'lat': Env.shelterALat, 'lng': Env.shelterALng},
        {'id': 'B', 'name': Env.shelterBName, 'lat': Env.shelterBLat, 'lng': Env.shelterBLng},
      ];

  Future<void> _load() async {
    setState(() {
      error = null;
      pos = null;
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() => error = 'Activa el GPS del dispositivo.');
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() => error = 'Permiso de ubicación denegado.');
        return;
      }

      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => pos = p);
    } catch (e) {
      setState(() => error = 'Error: $e');
    }
  }

  double _km(double lat, double lng) {
    if (pos == null) return 0;
    const R = 6371.0;
    final a = LatLng(pos!.latitude, pos!.longitude);
    final b = LatLng(lat, lng);
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final la1 = a.latitude * pi / 180;
    final la2 = b.latitude * pi / 180;
    final h = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(la1) * cos(la2);
    return 2 * R * asin(sqrt(h));
  }

  Future<void> _openRoute(double destLat, double destLng) async {
    if (pos == null) return;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${pos!.latitude},${pos!.longitude}'
      '&destination=$destLat,$destLng'
      '&travelmode=driving',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final center = pos == null ? LatLng(refugios.first['lat'], refugios.first['lng']) : LatLng(pos!.latitude, pos!.longitude);

    return AppScaffold(
      title: 'Mapa',
      actions: [
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
      ],
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.petadopt',
                ),
                MarkerLayer(
                  markers: [
                    if (pos != null)
                      Marker(
                        point: LatLng(pos!.latitude, pos!.longitude),
                        width: 46,
                        height: 46,
                        child: const Icon(Icons.my_location, size: 34),
                      ),
                    ...refugios.map((r) {
                      final id = r['id'] as String;
                      final isSel = selectedId == id;
                      return Marker(
                        point: LatLng(r['lat'] as double, r['lng'] as double),
                        width: 46,
                        height: 46,
                        child: GestureDetector(
                          onTap: () => setState(() => selectedId = id),
                          child: Icon(Icons.location_pin, size: 40, color: isSel ? Colors.purple : Colors.indigo),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          if (error != null) Padding(padding: const EdgeInsets.all(12), child: Text(error!, style: const TextStyle(color: Colors.red))),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Refugios cercanos', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...refugios.map((r) {
                  final id = r['id'] as String;
                  final name = r['name'] as String;
                  final lat = r['lat'] as double;
                  final lng = r['lng'] as double;
                  final isSel = selectedId == id;
                  final dist = pos == null ? null : _km(lat, lng);

                  return Card(
                    child: ListTile(
                      onTap: () => setState(() => selectedId = id),
                      title: Text(name),
                      subtitle: Text(dist == null ? 'Calculando...' : '${dist.toStringAsFixed(2)} km'),
                      trailing: isSel
                          ? IconButton(
                              tooltip: 'Abrir ruta',
                              icon: const Icon(Icons.alt_route),
                              onPressed: pos == null ? null : () => _openRoute(lat, lng),
                            )
                          : const Icon(Icons.circle_outlined),
                    ),
                  );
                }),
                const SizedBox(height: 6),
                const Text(
                  'Tip: Si el emulador está en USA verás distancias grandes. Cambia ubicación del emulador o coords en .env.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
