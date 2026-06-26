import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import './../providers/canchas_provider.dart';
import 'reservation_screen.dart'; 
import 'home_screen.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:geolocator/geolocator.dart';

class CanchasMapScreen extends StatefulWidget {
  const CanchasMapScreen({super.key});

  @override
  State<CanchasMapScreen> createState() => _CanchasMapScreenState();
}

class _CanchasMapScreenState extends State<CanchasMapScreen> {
  final MapController mapController = MapController();
  
  // 1. VARIABLE PARA GUARDAR TU UBICACIÓN
  LatLng? _miUbicacionActual;

  // 2. INIT STATE PARA PEDIR LA UBICACIÓN AL ABRIR EL MAPA
  @override
  void initState() {
    super.initState();
    _obtenerUbicacionDelUsuario();
  }

  // 3. FUNCIÓN QUE ACTIVA EL GPS
  Future<void> _obtenerUbicacionDelUsuario() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();

    if (mounted) {
      setState(() {
        _miUbicacionActual = LatLng(position.latitude, position.longitude);
      });
    }
  }

  void onMarkerTap(BuildContext context, CanchaFeed cancha) {
    final token = context.read<AuthProvider>().token ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReservationScreen(
          token: token, 
          facilityId: cancha.id,
          facilityName: cancha.nombre,
          facilityImage: cancha.imagenUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CanchasProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canchas Cercanas', style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: provider.isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: const LatLng(-24.7829, -65.4232), // Centro de Salta
                  initialZoom: 13.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    userAgentPackageName: 'com.fulbito.app',
                  ),
                  MarkerLayer(
                    markers: [
                      // 4. ESPARCIMOS LOS PINES DE LAS CANCHAS
                      ...provider.canchas.map((cancha) {
                        return Marker(
                          point: LatLng(cancha.latitud, cancha.longitud),
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () => onMarkerTap(context, cancha),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.greenAccent,
                              size: 45,
                            ),
                          ),
                        );
                      }), // <-- Ojo que le saqué el .toList() acá para que funcione con los 3 puntos (...)

                      // 5. AGREGAMOS TU PIN AZUL (Si ya tenemos la ubicación)
                      if (_miUbicacionActual != null)
                        Marker(
                          point: _miUbicacionActual!,
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.my_location,
                                color: Colors.blueAccent,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 15,
                bottom: 15, 
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in',
                      backgroundColor: Colors.green,
                      onPressed: () {
                        mapController.move(mapController.camera.center, mapController.camera.zoom + 1);
                      },
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out',
                      backgroundColor: Colors.green,
                      onPressed: () {
                        mapController.move(mapController.camera.center, mapController.camera.zoom - 1);
                      },
                      child: const Icon(Icons.remove, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}