import 'package:flutter/material.dart';

// 1. Modelo limpio, solo con los datos visuales
class ReservaActiva {
  final String nombreCancha;
  final String direccion;
  final String fecha;
  final String hora;

  ReservaActiva({
    required this.nombreCancha,
    required this.direccion,
    required this.fecha,
    required this.hora,
  });
}

// 2. La pantalla ahora es un Widget puro para encajar en la barra de navegación
class BookingsScreen extends StatelessWidget {
  // Como sacamos el mapa, ya no necesitamos pedir la función onNavigate.
  // Esto hace que sea súper fácil de instanciar.
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de prueba
    final List<ReservaActiva> misReservas = [
      ReservaActiva(
        nombreCancha: 'Complejo El 10',
        direccion: 'Av. Reyes Católicos 1500, Salta',
        fecha: 'Hoy',
        hora: '21:00 hs',
      ),
      ReservaActiva(
        nombreCancha: 'Canchas La Loma',
        direccion: 'Av. Bolivia 5150, Salta',
        fecha: 'Jueves 11 de Junio',
        hora: '19:30 hs',
      ),
    ];

    // Retornamos directamente el Padding, sin Scaffold ni AppBar
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior con el Título y el Botón de Historial integrados
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reservas Activas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Azul oscuro
                ),
              ),
              // Botón de historial reubicado acá para no usar un AppBar extra
              TextButton.icon(
                onPressed: () {
                  // TODO: Navegar a historial_screen.dart
                  print('Ir al historial');
                },
                icon: const Icon(Icons.history, color: Colors.green),
                label: const Text(
                  'Historial',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Lista de tarjetas
          Expanded(
            child: ListView.builder(
              itemCount: misReservas.length,
              itemBuilder: (context, index) {
                final reserva = misReservas[index];
                
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Ya no hay navegación al mapa acá
                      print('Clic en reserva: ${reserva.nombreCancha}');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sports_soccer,
                              color: Colors.green,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reserva.nombreCancha,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  reserva.direccion,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.blueGrey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${reserva.fecha} - ${reserva.hora}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}