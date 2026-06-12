import 'package:flutter/material.dart';

// 1. Agregamos el campo imagenUrl al modelo
class CanchaFeed {
  final String id;
  final String nombre;
  final String ubicacion;
  final String precio;
  final String imagenUrl; // <-- Nuevo campo para el link de internet
  bool esFavorita;

  CanchaFeed({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.precio,
    required this.imagenUrl,
    this.esFavorita = false,
  });
}

class InicioTab extends StatefulWidget {
  const InicioTab({super.key});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  // 2. Cargamos links reales de fotos de canchas (usando Unsplash)
  List<CanchaFeed> canchas = [
    CanchaFeed(
      id: '1', 
      nombre: 'Complejo El 10', 
      ubicacion: 'Av. Reyes Católicos 1500', 
      precio: '\$15.000 / hr',
      imagenUrl: 'data:image/jpeg;base64,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',
    ),
    CanchaFeed(
      id: '2', 
      nombre: 'Canchas La Loma', 
      ubicacion: 'Av. Bolivia 5150', 
      precio: '\$12.000 / hr',
      imagenUrl: 'https://picsum.photos/id/1015/800/400',
    ),
    CanchaFeed(
      id: '3', 
      nombre: 'El Monumentalito', 
      ubicacion: 'Tres Cerritos', 
      precio: '\$14.000 / hr',
      imagenUrl: 'https://argentina.as.com/argentina/2020/05/26/futbol/1590502177_250133.html',
    ),
    CanchaFeed(
      id: '4', 
      nombre: 'Fulbito 5', 
      ubicacion: 'Zona Centro', 
      precio: '\$10.000 / hr',
      imagenUrl: 'https://images.unsplash.com/photo-1459865264687-595d652de67e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    ),
    CanchaFeed(
      id: '5', 
      nombre: 'La Redonda', 
      ubicacion: 'San Lorenzo', 
      precio: '\$18.000 / hr',
      imagenUrl: 'https://pbs.twimg.com/media/DrvIoSKXQAE4wJl.jpg',
    ),
  ];

  void _toggleFavorito(int index) {
    setState(() {
      canchas[index].esFavorita = !canchas[index].esFavorita;
      
      canchas.sort((a, b) {
        if (a.esFavorita && !b.esFavorita) return -1;
        if (!a.esFavorita && b.esFavorita) return 1;
        return 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: canchas.length,
      itemBuilder: (context, index) {
        final cancha = canchas[index];
        
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 20.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // 3. Acá reemplazamos el fondo verde por la imagen de internet
                  Image.network(
                    cancha.imagenUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover, // Esto recorta la imagen para que llene el rectángulo sin deformarse
                    // Un pequeño extra profesional: mientras carga la imagen, mostramos un circulito
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child; // Si ya cargó, muestra la foto
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.greenAccent),
                        ),
                      );
                    },
                  ),
                  // Botón de Favorito
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        cancha.esFavorita ? Icons.favorite : Icons.favorite_border,
                        color: cancha.esFavorita ? Colors.red : Colors.white, // Cambié el gris por blanco para que resalte sobre las fotos
                        size: 32,
                      ),
                      onPressed: () => _toggleFavorito(index),
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
                          Text(
                            cancha.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cancha.ubicacion,
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      cancha.precio,
                      style: const TextStyle(
                        color: Colors.greenAccent, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 16
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}