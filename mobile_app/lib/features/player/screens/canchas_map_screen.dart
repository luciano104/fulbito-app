import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import './../providers/canchas_provider.dart';
import 'review_form_screen.dart'; 
import 'home_screen.dart';

class CanchasMapScreen extends StatefulWidget {
  const CanchasMapScreen({super.key});

  @override
  State<CanchasMapScreen> createState() => _CanchasMapScreenState();
}

class _CanchasMapScreenState extends State<CanchasMapScreen> {
  final MapController mapController = MapController();

  // Función que se ejecuta al tocar un PIN rojo del mapa
  void onMarkerTap(BuildContext context, CanchaFeed cancha) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewFormScreen(cancha: cancha),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Enganchamos el mapa a tu provider global
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
                  initialCenter: const LatLng(-24.7829, -65.4232), // Coordenadas centrales
                  initialZoom: 13.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    userAgentPackageName: 'com.fulbito.app',
                  ),
                  MarkerLayer(
                    // Transformamos cada cancha en un Marker del mapa
                    markers: provider.canchas.map((cancha) {
                      return Marker(
                        point: LatLng(cancha.latitud, cancha.longitud),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () => onMarkerTap(context, cancha),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.greenAccent, // Estilo fulbito
                            size: 45,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              // Botones de Zoom del profe
              Positioned(
                right: 15,
                bottom: 15, // Los pasé abajo para que no tapen nada arriba
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