import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart'; 
import './../providers/reservas_provider.dart';
import 'package:mobile_app/features/player/screens/historial_screen.dart';

class ReservaActiva {
  final String id;
  final String nombreCancha;
  final String direccion;
  final String fecha;
  final String hora;
  final String estado;
  final bool hasReview; // NUEVO

  ReservaActiva({
    required this.id,
    required this.nombreCancha,
    required this.direccion,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.hasReview, // NUEVO
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
      hasReview: json['has_review'] ?? false, // NUEVO: Django manda esto gracias al serializer de tu amigo
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
    Future.microtask(() {
      // Acá tu compañero ya conectó el token real del usuario logueado
      final token = context.read<AuthProvider>().token!;
      Provider.of<ReservasProvider>(context, listen: false).obtenerReservas(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final reservasProvider = Provider.of<ReservasProvider>(context);
    final reservasActivas = reservasProvider.misReservas.where((r) => r.estado != 'completed').toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reservas Activas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const HistorialScreen())
                  );
                },
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
              : reservasActivas.isEmpty 
              ? const Center(child: Text("No tenés reservas activas", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)))
              : ListView.builder(
                  itemCount: reservasActivas.length,
                  itemBuilder: (context, index) {
                    final reserva = reservasActivas[index];
                    
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Colors.grey[900], 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                  Text(reserva.nombreCancha, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis,),
                                  const SizedBox(height: 4),
                                  Text(reserva.direccion, style: TextStyle(color: Colors.grey[400], fontSize: 13), overflow: TextOverflow.ellipsis,),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 13, color: Colors.greenAccent),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${reserva.fecha} · ${reserva.hora}',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.greenAccent,
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: reserva.estado == 'confirmed' ? Colors.green.withOpacity(0.2) : 
                                  reserva.estado == 'pending' ? Colors.orange.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                reserva.estado == 'confirmed' ? 'CONFIRMADA' : reserva.estado == 'pending' ? 'PENDIENTE': 'CANCELADA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: reserva.estado == 'confirmed'
                                      ? Colors.green
                                      : reserva.estado == 'pending' ?Colors.orange
                                      : Colors.red,
                                ),
                              ),
                            )
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