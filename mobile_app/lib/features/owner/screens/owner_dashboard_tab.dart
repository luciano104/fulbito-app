import 'package:flutter/material.dart';

class OwnerDashboardTab extends StatefulWidget {
  const OwnerDashboardTab({super.key});

  @override
  State<OwnerDashboardTab> createState() => _OwnerDashboardTabState();
}

class _OwnerDashboardTabState extends State<OwnerDashboardTab> {
  // Datos simulados (Mocks) que más adelante nos dará el Django de Luciano
  final int _turnosReservados = 8;
  final double _porcentajeOcupacion = 66.6;
  final double _ingresosEstimados = 32000.0;
  final double _calificacionPromedio = 4.8;
  final int _totalResenas = 42;

  // Estado de las canchas (Verdadero = Disponible, Falso = Mantenimiento)
  bool _cancha1Activa = true;
  bool _cancha2Activa = true;
  bool _cancha3Activa = false; // Supongamos que está en mantenimiento

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // SECCIÓN 1: RESUMEN OPERATIVO DEL DÍA (Tarjetas)
          // ==================================================
          const Text(
            'Resumen del Día',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildStatCard('Turnos hoy', '$_turnosReservados', Icons.event_available, Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard('Ocupación', '${_porcentajeOcupacion.toStringAsFixed(1)}%', Icons.pie_chart, Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildStatCard('Ingresos Est.', '\$${_ingresosEstimados.toStringAsFixed(0)}', Icons.monetization_on, Colors.green),
              const SizedBox(width: 12),
              // Tarjeta de Reputación
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Reputación', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text('$_calificacionPromedio', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('($_totalResenas opiniones)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          // ==================================================
          // SECCIÓN 2: CONTROL DE CANCHAS (Interruptores rápidos)
          // ==================================================
          const Text(
            'Estado de las Canchas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pausá una cancha al instante por tareas de mantenimiento.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),

          _buildCanchaSwitchTile('Cancha 1 - Fútbol 5 (Pasto)', _cancha1Activa, (valor) {
            setState(() => _cancha1Activa = valor);
          }),
          _buildCanchaSwitchTile('Cancha 2 - Fútbol 5 (Pasto)', _cancha2Activa, (valor) {
            setState(() => _cancha2Activa = valor);
          }),
          _buildCanchaSwitchTile('Cancha 3 - Fútbol 5 (Techada)', _cancha3Activa, (valor) {
            setState(() => _cancha3Activa = valor);
          }),
        ],
      ),
    );
  }

  // --- WIDGET AUXILIAR: Diseña las tarjetas estadísticas superiores ---
  Widget _buildStatCard(String titulo, String valor, IconData icono, Color colorIcono) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icono, color: colorIcono, size: 28),
              const SizedBox(height: 8),
              Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 4),
              Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET AUXILIAR: Diseña la fila de cada cancha con su Switch ---
  Widget _buildCanchaSwitchTile(String nombreCancha, bool estaActiva, ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: SwitchListTile(
        title: Text(nombreCancha, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          estaActiva ? 'Disponible para turnos' : 'Pausada por Mantenimiento',
          style: TextStyle(color: estaActiva ? Colors.green : Colors.red, fontSize: 13),
        ),
        value: estaActiva,
        activeColor: Colors.green,
        onChanged: onChanged,
      ),
    );
  }
}