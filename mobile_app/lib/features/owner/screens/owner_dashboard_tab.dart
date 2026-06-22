import 'package:flutter/material.dart';
import 'package:mobile_app/features/owner/providers/owner_dashboard_provider.dart';
import 'package:provider/provider.dart';


// ─────────────────────────────────────────────
//  MODELOS
// ─────────────────────────────────────────────
class CourtStatus {
  final int id;
  final String teamSize;
  final String surface;
  final double price;
  bool available;
 
  CourtStatus({
    required this.id,
    required this.teamSize,
    required this.surface,
    required this.price,
    required this.available,
  });
 
  factory CourtStatus.fromJson(Map<String, dynamic> json) => CourtStatus(
        id: json['id'],
        teamSize: json['team_size'],
        surface: json['surface'],
        price: double.parse(json['price'].toString()),
        available: json['available'],
      );
}
 
class DashboardStats {
  final int turnosHoy;
  final double porcentajeOcupacion;
  final double ingresosEstimados;
  final double avgRating;
  final int totalReviews;
 
  DashboardStats({
    required this.turnosHoy,
    required this.porcentajeOcupacion,
    required this.ingresosEstimados,
    required this.avgRating,
    required this.totalReviews,
  });
}

// ─────────────────────────────────────────────
//  PANTALLA
// ─────────────────────────────────────────────

class OwnerDashboardTab extends StatefulWidget {
  final String token;
  final int facilityId;

  const OwnerDashboardTab({
    super.key,
    required this.token,
    required this.facilityId,
    });

  @override
  State<OwnerDashboardTab> createState() => _OwnerDashboardTabState();
}

class _OwnerDashboardTabState extends State<OwnerDashboardTab> {
  @override
  void initState(){
    super.initState();
    Future.microtask(() =>
        Provider.of<OwnerDashboardProvider>(context, listen: false)
            .cargarDashboard(widget.token, widget.facilityId));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerDashboardProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }
 
    if (provider.errorMessage != null) {
      return Center(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)));
    }
 
    final stats = provider.stats;

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
              _buildStatCard('Turnos hoy', '${stats?.turnosHoy ?? 0}', Icons.event_available, Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard('Ocupación', '${stats?.porcentajeOcupacion.toStringAsFixed(1) ?? '0'}%', Icons.pie_chart, Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildStatCard('Ingresos Est.', '\$${stats?.ingresosEstimados.toStringAsFixed(0) ?? '0'}', Icons.monetization_on, Colors.green),
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
                            Text('${stats?.avgRating ?? 0}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('(${stats?.totalReviews ?? 0} opiniones)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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

          ...provider.courts.map((court) => Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: SwitchListTile(
              title: Text('${court.teamSize} - ${court.surface}', style: const TextStyle(fontWeight: FontWeight.w500),),
              subtitle: Text(court.available ? 'Disponible para turnos': 'Pausada por Mantenimiento', style: TextStyle(color: court.available ? Colors.green : Colors.red, fontSize: 13),),
              value: court.available,
              activeColor: Colors.green,
              onChanged: (_) => provider.toggleDisponibilidad(widget.token, court.id),
              ),
          )),
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
}