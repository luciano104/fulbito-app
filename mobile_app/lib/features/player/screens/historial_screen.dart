import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/player/providers/reservas_provider.dart';
import 'package:mobile_app/features/player/screens/booking_screen.dart'; 

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final token = context.read<AuthProvider>().token!;
      context.read<ReservasProvider>().obtenerReservas(token);
    });
  }

  // --- LÓGICA DEL POP-UP (Inspirado en el código de tu profe) ---
  void _mostrarDialogoResena(BuildContext context, String reservaId, String nombreCancha) {
    int rating = 5; // Por defecto 5 estrellas
    final comentarioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        // Usamos StatefulBuilder para que el Slider se actualice dentro del Pop-up
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text('Calificar $nombreCancha', style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Puntuación', style: TextStyle(color: Colors.white70)),
                    Slider(
                      activeColor: Colors.green,
                      inactiveColor: Colors.grey[700],
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: rating.toString(),
                      value: rating.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          rating = value.toInt();
                        });
                      },
                    ),
                    Text('$rating ⭐', style: const TextStyle(color: Colors.amber, fontSize: 20)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: comentarioController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Tu comentario',
                        labelStyle: const TextStyle(color: Colors.green),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                    if (comentarioController.text.isEmpty) return;
                    
                    final token = context.read<AuthProvider>().token!;
                    final exito = await context.read<ReservasProvider>().enviarResena(
                      token, 
                      reservaId, 
                      rating, 
                      comentarioController.text
                    );

                    if (exito && mounted) {
                      Navigator.pop(context); // Cerramos el pop-up
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Reseña publicada!'), backgroundColor: Colors.green),
                      );
                      // Recargamos la lista para que desaparezca el botón
                      context.read<ReservasProvider>().obtenerReservas(token);
                    }
                  },
                  child: const Text('PUBLICAR', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reservasProvider = context.watch<ReservasProvider>();
    
    // Filtramos para mostrar SOLO las reservas pasadas o confirmadas (Historial)
    // Asumimos que si no es PENDIENTE, va al historial.
    final historial = reservasProvider.misReservas
        .where((r) => r.estado != 'pending')
        .toList();

    return Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER SIN APPBAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.green),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Historial de Reservas',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 48), // Para centrar el texto
                ],
              ),
            ),
            
            // --- LISTA DE CANCHAS ---
            Expanded(
              child: reservasProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : historial.isEmpty
                ? const Center(child: Text("No hay historial disponible", style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: historial.length,
                    itemBuilder: (context, index) {
                      final reserva = historial[index];
                      // Para habilitar la reseña: debe estar finalizada y no tener reseña previa
                      final puedeDejarResena = (reserva.estado == 'completed' || reserva.estado == 'finalizada') && !reserva.hasReview;

                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reserva.nombreCancha, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 8),
                              Text('${reserva.fecha} · ${reserva.hora}', style: const TextStyle(color: Colors.greenAccent)),
                              const SizedBox(height: 12),
                              
                              if (puedeDejarResena)
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.amber),
                                      foregroundColor: Colors.amber,
                                    ),
                                    icon: const Icon(Icons.star_outline),
                                    label: const Text('Dejar Reseña'),
                                    onPressed: () => _mostrarDialogoResena(context, reserva.id, reserva.nombreCancha),
                                  ),
                                ),
                              if (reserva.hasReview)
                                const Text('⭐ Ya calificaste este complejo', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
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