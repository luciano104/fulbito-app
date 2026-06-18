import 'package:flutter/material.dart';

class OwnerBookingsTab extends StatefulWidget {
  const OwnerBookingsTab({super.key});

  @override
  State<OwnerBookingsTab> createState() => _OwnerBookingsTabState();
}

class _OwnerBookingsTabState extends State<OwnerBookingsTab> {
  // Lista simulada de reservas pendientes (Mocks)
  // Cuando Luciano tenga el endpoint en Django, mapearemos esto a un modelo
  final List<Map<String, dynamic>> _reservasPendientes = [
    {
      'id': 1,
      'jugador': 'Walter R.',
      'cancha': 'Cancha 1 - Fútbol 5',
      'fecha': 'Hoy - 16 de Junio',
      'hora': '20:00 a 21:00',
      'precio': '\$12.000',
    },
    {
      'id': 2,
      'jugador': 'Luciano A.',
      'cancha': 'Cancha 3 - Fútbol 5 Techada',
      'fecha': 'Hoy - 16 de Junio',
      'hora': '22:00 a 23:00',
      'precio': '\$15.000',
    },
  ];

  // Lista simulada de comentarios/opiniones del complejo
  final List<Map<String, dynamic>> _comentarios = [
    {'usuario': 'Gaston M.', 'estrellas': 5, 'texto': 'Excelente las luces de la cancha 1, no encandilan nada.'},
    {'usuario': 'Rodrigo S.', 'estrellas': 4, 'texto': 'Muy buena atención en el buffet, los termos con agua caliente de diez.'},
  ];

  void _aceptarReserva(int id, String jugador) {
    setState(() {
      _reservasPendientes.removeWhere((reserva) => reserva['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Reserva de $jugador ACEPTADA (Notificando a Django...)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rechazarReserva(int id, String jugador) {
    setState(() {
      _reservasPendientes.removeWhere((reserva) => reserva['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Reserva de $jugador RECHAZADA (Bloque liberado)'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // SECCIÓN 1: SOLICITUDES ENTRANTES
          // ==================================================
          Row(
            children: [
              const Text('Solicitudes Pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              if (_reservasPendientes.isNotEmpty)
                Badge(label: Text('${_reservasPendientes.length}'), backgroundColor: Colors.amber),
            ],
          ),
          const SizedBox(height: 12),

          if (_reservasPendientes.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('🎉 ¡No hay solicitudes pendientes por ahora!')),
              ),
            )
          else
            ..._reservasPendientes.map((reserva) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(reserva['jugador'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(reserva['precio'], style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.sports_soccer, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(reserva['cancha'], style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('${reserva['fecha']} | ${reserva['hora']}', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _rechazarReserva(reserva['id'], reserva['jugador']),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Rechazar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _aceptarReserva(reserva['id'], reserva['jugador']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Confirmar Turno'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          // ==================================================
          // SECCIÓN 2: FEEDBACK / OPINIONES DE CLIENTES
          // ==================================================
          const Text('Reseñas Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ..._comentarios.map((comment) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Text(comment['usuario'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(
                      comment['estrellas'],
                      (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(comment['texto'], style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            );
          }),
        ],
      ),
    );
  }
}