import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  /// Coordenadas iniciales
  final double? initialLat;
  final double? initialLng;

  const LocationPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _pinPosition;
  final MapController _mapController = MapController();

  // Centro de Salta Capital como punto de partida
  static const LatLng _saltaCenter = LatLng(-24.7829, -65.4232);

  @override
  void initState() {
    super.initState();
    _pinPosition = (widget.initialLat != null && widget.initialLng != null)
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _saltaCenter;
  }

  void _onMapTap(TapPosition _, LatLng point) {
    setState(() => _pinPosition = point);
  }

  void _confirmar() {
    // Devuelve las coordenadas al formulario
    Navigator.pop(context, _pinPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir ubicación'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // ── MAPA ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pinPosition,
              initialZoom: 15,
              onTap: _onMapTap, // mover el pin tocando el mapa
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.fulbito.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pinPosition,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── INSTRUCCIÓN SUPERIOR ──
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Tocá el mapa para mover el pin a la ubicación de tu complejo',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87, fontSize: 13),
              ),
            ),
          ),

          // ── COORDENADAS EN TIEMPO REAL ──
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Lat: ${_pinPosition.latitude.toStringAsFixed(6)}  '
                'Lng: ${_pinPosition.longitude.toStringAsFixed(6)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 13,
                    fontFamily: 'monospace'),
              ),
            ),
          ),

          // ── BOTONES ZOOM ──
          Positioned(
            right: 15,
            bottom: 110,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  backgroundColor: Colors.green,
                  onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  backgroundColor: Colors.green,
                  onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  ),
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
              ],
            ),
          ),

          // ── BOTÓN CONFIRMAR ──
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: _confirmar,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                'Confirmar ubicación',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}