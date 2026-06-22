import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importamos Provider
import './../providers/reservas_provider.dart'; // Ajustá la ruta

class ReservaActiva {
  final String id;
  final String nombreCancha;
  final String direccion;
  final String fecha;
  final String hora;
  final String estado;

  ReservaActiva({
    required this.id,
    required this.nombreCancha,
    required this.direccion,
    required this.fecha,
    required this.hora,
    required this.estado,
  });

  factory ReservaActiva.fromJson(Map<String, dynamic> json) {
    final startTime = json['start_time'] != null ? json['start_time'].toString().substring(0, 5) : '';
    final endTime = json['end_time'] != null ? json['end_time'].toString().substring(0, 5) : '';
    
    return ReservaActiva(
      id: json['id'].toString(),
      nombreCancha: json['facility_name'] ?? 'Complejo',
      direccion: 'Ubicación en el complejo', 
      fecha: json['date'] ?? 'Fecha a confirmar',
      hora: '$startTime - $endTime',
      estado: json['status'] ?? 'PENDIENTE',
    );
  }
}

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<ReservasProvider>(context, listen: false).obtenerReservas()
    );
  }

  @override
  Widget build(BuildContext context) {
    // Nos conectamos al Provider de reservas
    final reservasProvider = Provider.of<ReservasProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- ENCABEZADO ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reservas Activas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              TextButton.icon(
                onPressed: () => print('Ir al historial'),
                icon: const Icon(Icons.history, color: Colors.green),
                label: const Text('Historial', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // --- LISTA DESDE PROVIDER ---
          Expanded(
            child: reservasProvider.isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.green))
              : reservasProvider.misReservas.isEmpty 
                  ? const Center(child: Text("No tenés reservas activas\n(O falta iniciar sesión)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)))
                  : ListView.builder(
                      itemCount: reservasProvider.misReservas.length,
                      itemBuilder: (context, index) {
                        final reserva = reservasProvider.misReservas[index];
                        
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          color: Colors.grey[900], 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.sports_soccer, color: Colors.green, size: 30),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(reserva.nombreCancha, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                      const SizedBox(height: 4),
                                      Text(reserva.direccion, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 14, color: Colors.greenAccent),
                                          const SizedBox(width: 4),
                                          Text('${reserva.fecha} - ${reserva.hora}', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.greenAccent)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: reserva.estado == 'CONFIRMADA' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    reserva.estado,
                                    style: TextStyle(fontSize: 12, color: reserva.estado == 'CONFIRMADA' ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
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
    );
  }
}