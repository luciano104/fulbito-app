import 'package:flutter/material.dart';
import 'package:mobile_app/features/owner/providers/owner_bookings_provider.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────
//  MODELOS — exportados para el provider
// ─────────────────────────────────────────────
 
class OwnerReservation {
  final int id;
  final String playerName;
  final String facilityName;
  final String courtType;
  final String date;
  final String startTime;
  final String endTime;
  String status;
 
  OwnerReservation({
    required this.id,
    required this.playerName,
    required this.facilityName,
    required this.courtType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });
 
  factory OwnerReservation.fromJson(Map<String, dynamic> json) => OwnerReservation(
        id: json['id'],
        playerName: 'Jugador #${json['player']}',
        facilityName: json['facility_name'] ?? '',
        courtType: json['court_type'] ?? '',
        date: json['date'],
        startTime: json['start_time'] != null
            ? json['start_time'].toString().substring(0, 5)
            : '',
        endTime: json['end_time'] != null
            ? json['end_time'].toString().substring(0, 5)
            : '',
        status: json['status'],
      );
 
  bool get isPending => status == 'pending';
}
 
class OwnerReview {
  final int rating;
  final String comment;
 
  OwnerReview({required this.rating, required this.comment});
 
  factory OwnerReview.fromJson(Map<String, dynamic> json) => OwnerReview(
        rating: json['rating'],
        comment: json['comment'] ?? '',
      );
}
 
// ─────────────────────────────────────────────
//  PANTALLA
// ─────────────────────────────────────────────
class OwnerBookingsTab extends StatefulWidget {
  final String token;
  final int facilityId;
  
  const OwnerBookingsTab({
      super.key,
      required this.token,
      required this.facilityId,
    });

  @override
  State<OwnerBookingsTab> createState() => _OwnerBookingsTabState();
}

class _OwnerBookingsTabState extends State<OwnerBookingsTab> {
  @override
  void initState(){
    super.initState();
    Future.microtask(() =>
      Provider.of<OwnerBookingsProvider>(context, listen: false)
        .cargarReservas(widget.token, widget.facilityId));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerBookingsProvider>(context);

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
              if (provider.pendingReservations.isNotEmpty)
                Badge(label: Text('${provider.pendingReservations.length}'), backgroundColor: Colors.amber),
            ],
          ),
          const SizedBox(height: 12),

          if(provider.isLoading) const Center(child: CircularProgressIndicator(color: Colors.green))
          else if (provider.pendingReservations.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('🎉 ¡No hay solicitudes pendientes por ahora!')),
              ),
            )
          else
            ...provider.pendingReservations.map((reserva) => Card(
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
                          Text(reserva.playerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(reserva.courtType, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.sports_soccer, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(reserva.facilityName, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('${reserva.date} | ${reserva.startTime} - ${reserva.endTime}', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => provider.rechazar(widget.token, reserva.id),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Rechazar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => provider.confirmar(widget.token, reserva.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Confirmar Turno'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          // ==================================================
          // SECCIÓN 2: FEEDBACK / OPINIONES DE CLIENTES
          // ==================================================
          const Text('Reseñas Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (provider.reviews.isEmpty)
            const Text('Aún no hay reseñas.',
                style: TextStyle(color: Colors.grey))
          else
            ...provider.reviews.map((review) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(children: [
                Row(
                  children: List.generate(
                    review.rating,
                    (_) => const Icon(Icons.star, color: Colors.amber, size: 16),
                  ),
                ),
              ]),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(review.comment,
                    style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            )),
        ],
      ),
    );
  }
}