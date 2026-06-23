import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import './../providers/canchas_provider.dart'; 
import 'reservation_screen.dart'; 

class CanchaFeed {
  final String id;
  final String nombre;
  final String ubicacion;
  final String precio;
  final String imagenUrl;
  final double latitud;  
  final double longitud; 
  bool esFavorita;

  CanchaFeed({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.precio,
    required this.imagenUrl,
    required this.latitud,
    required this.longitud,
    this.esFavorita = false,
  });

  factory CanchaFeed.fromJson(Map<String, dynamic> json) {
    return CanchaFeed(
      id: json['id'].toString(),
      nombre: json['name'] ?? 'Complejo sin nombre',
      ubicacion: json['address'] ?? 'Ubicación no especificada',
      // ¡El backend envía base_price como número! 
      precio: json['base_price'] != null ? '\$${json['base_price']} / hr' : '\$10.000 / hr',
      imagenUrl: json['image'] ?? 'https://images.unsplash.com/photo-1459865264687-595d652de67e?...',
      // Confirmado: el backend manda latitud y longitud, pero probabemente como strings o floats
      latitud: json['latitude'] != null ? double.parse(json['latitude'].toString()) : -24.7829,
      longitud: json['longitude'] != null ? double.parse(json['longitude'].toString()) : -65.4232,
      esFavorita: false,
    );
  }
}

class InicioTab extends StatefulWidget {
  const InicioTab({super.key});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<CanchasProvider>(context, listen: false).obtenerCanchas()
    );
  }

  @override
  Widget build(BuildContext context) {
    final canchasProvider = Provider.of<CanchasProvider>(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.person, color: Colors.green),
                  tooltip: 'Perfil',
                  onPressed: () => print('Clic en Perfil'),
                ),
                const Text(
                  'Hola Jugador',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(width: 48), 
              ],
            ),
            const SizedBox(height: 16), 
            
            
            Expanded(
              child: canchasProvider.isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : canchasProvider.canchas.isEmpty 
                    ? const Center(child: Text("No hay complejos disponibles aún", style: TextStyle(color: Colors.white, fontSize: 16)))
                    : ListView.builder(
                        padding: EdgeInsets.zero, 
                        itemCount: canchasProvider.canchas.length,
                        itemBuilder: (context, index) {
                          final cancha = canchasProvider.canchas[index];
                          
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReservationScreen(
                                    token: 'Bearer token_falso', // <-- Token temporal
                                    facilityId: cancha.id,
                                    facilityName: cancha.nombre,
                                    facilityImage: cancha.imagenUrl,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 20.0),
                              color: Colors.grey[900], 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Image.network(
                                        cancha.imagenUrl,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover, 
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          height: 180, width: double.infinity, color: Colors.grey[850],
                                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8, right: 8,
                                        child: IconButton(
                                          icon: Icon(
                                            cancha.esFavorita ? Icons.favorite : Icons.favorite_border,
                                            color: cancha.esFavorita ? Colors.red : Colors.white, size: 32,
                                          ),
                                          onPressed: () => canchasProvider.toggleFavorito(index),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(cancha.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 6),
                                              Text(cancha.ubicacion, style: TextStyle(color: Colors.grey[400], fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                        Text(cancha.precio, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}