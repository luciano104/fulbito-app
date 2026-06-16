import 'package:flutter/material.dart';

class OwnerGridTab extends StatefulWidget {
  const OwnerGridTab({super.key});

  @override
  State<OwnerGridTab> createState() => _OwnerGridTabState();
}

class _OwnerGridTabState extends State<OwnerGridTab> {
  // Lista simulada de horarios (Mocks) para el día actual
  final List<Map<String, dynamic>> _bloquesHorarios = [
    {
      'hora': '17:00 - 18:00',
      'cancha1': {'estado': 'Libre', 'jugador': ''},
      'cancha2': {'estado': 'Libre', 'jugador': ''},
      'cancha3': {'estado': 'Reservado', 'jugador': 'Gaston M.'},
    },
    {
      'hora': '18:00 - 19:00',
      'cancha1': {'estado': 'Reservado', 'jugador': 'Rodrigo S.'},
      'cancha2': {'estado': 'Libre', 'jugador': ''},
      'cancha3': {'estado': 'Reservado', 'jugador': 'Diego R.'},
    },
    {
      'hora': '19:00 - 20:00',
      'cancha1': {'estado': 'Reservado', 'jugador': 'Walter R.'},
      'cancha2': {'estado': 'Reservado', 'jugador': 'Luciano A.'},
      'cancha3': {'estado': 'Mantenimiento', 'jugador': ''},
    },
    {
      'hora': '20:00 - 21:00',
      'cancha1': {'estado': 'Libre', 'jugador': ''},
      'cancha2': {'estado': 'Reservado', 'jugador': 'Enzo A.'},
      'cancha3': {'estado': 'Libre', 'jugador': ''},
    },
    {
      'hora': '21:00 - 22:00',
      'cancha1': {'estado': 'Reservado', 'jugador': 'Lucas T.'},
      'cancha2': {'estado': 'Libre', 'jugador': ''},
      'cancha3': {'estado': 'Libre', 'jugador': ''},
    },
  ];

  Color _getColorPorEstado(String estado) {
    switch (estado) {
      case 'Reservado':
        return Colors.red.shade100;
      case 'Mantenimiento':
        return Colors.orange.shade100;
      case 'Libre':
      default:
        return Colors.green.shade100;
    }
  }

  Color _getTextColorPorEstado(String estado) {
    switch (estado) {
      case 'Reservado':
        return Colors.red.shade900;
      case 'Mantenimiento':
        return Colors.orange.shade900;
      case 'Libre':
      default:
        return Colors.green.shade900;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grilla Horaria de Hoy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Vista general de la ocupación por cancha del complejo.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Renderizamos cada bloque horario en formato de tarjeta expandida
          ..._bloquesHorarios.map((bloque) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila del Horario
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          bloque['hora'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Grilla de las 3 canchas en paralelo
                    Row(
                      children: [
                        _buildCanchaStatusBox('Cancha 1', bloque['cancha1']),
                        const SizedBox(width: 8),
                        _buildCanchaStatusBox('Cancha 2', bloque['cancha2']),
                        const SizedBox(width: 8),
                        _buildCanchaStatusBox('Cancha 3', bloque['cancha3']),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- WIDGET AUXILIAR: Arma el casillero de cada cancha individual ---
  Widget _buildCanchaStatusBox(String nombreCancha, Map<String, dynamic> datosCancha) {
    String estado = datosCancha['estado'];
    String jugador = datosCancha['jugador'];

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getColorPorEstado(estado),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _getTextColorPorEstado(estado).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              nombreCancha,
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: _getTextColorPorEstado(estado)
              ),
            ),
            const SizedBox(height: 4),
            Text(
              estado,
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w500,
                color: _getTextColorPorEstado(estado)
              ),
            ),
            if (jugador.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                jugador,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.black87, fontStyle: FontStyle.italic),
              ),
            ]
          ],
        ),
      ),
    );
  }
}