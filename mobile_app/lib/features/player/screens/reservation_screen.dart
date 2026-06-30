import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/canchas_provider.dart';
import '../providers/reservas_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservationScreen extends StatefulWidget {
  final String token; 
  final String facilityId;
  final String facilityName;
  final String facilityImage;

  const ReservationScreen({
    super.key,
    required this.token,
    required this.facilityId,
    required this.facilityName,
    required this.facilityImage,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedCourtId;
  String? _selectedScheduleId;
  String? _selectedTimeLabel;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final canchasProv = context.read<CanchasProvider>();
     
      await canchasProv.cargarDetallesDelComplejo(widget.token, widget.facilityId);
      
      if (canchasProv.canchasDelComplejo.isNotEmpty) {
        setState(() {
          _selectedCourtId = canchasProv.canchasDelComplejo.first['id'].toString();
        });
        _consultarHorariosBackend();
      }
    });
  }

  String _formatearFecha(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _consultarHorariosBackend() {
    if (_selectedCourtId != null) {
      final fechaStr = _formatearFecha(_selectedDate);
     
      context.read<ReservasProvider>().cargarHorariosDeCancha(widget.token, _selectedCourtId!, fechaStr);
    }
  }

  List<DateTime> get _next7Days {
    return List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
  }

  String _getDiaSemana(int weekday) {
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return dias[weekday - 1];
  }

  Future<void> _confirmarReservaReal() async {
    if (_selectedScheduleId == null) return;
    
    final reservasProv = context.read<ReservasProvider>();
    final fechaStr = _formatearFecha(_selectedDate);

    final exito = await reservasProv.solicitarReserva(widget.token, _selectedScheduleId!, fechaStr);

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Reserva registrada para las $_selectedTimeLabel hs!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un problema al procesar la reserva.'), backgroundColor: Colors.red),
      );
    }
  }
  
  Future<void> _procesarPagoMercadoPago() async {
    if (_selectedScheduleId == null) return;
    
    final reservasProv = context.read<ReservasProvider>();
    final fechaStr = _formatearFecha(_selectedDate);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
    );

    final urlPago = await reservasProv.crearPreferenciaPago(
      widget.token, 
      _selectedScheduleId!, 
      fechaStr
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (urlPago != null) {
      final uri = Uri.parse(urlPago);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Reserva PAGADA y confirmada con éxito!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); 
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con Mercado Pago.'), backgroundColor: Colors.red),
      );
    }
  }

  void _mostrarOpcionesDePago() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Cómo querés pagar?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.storefront, color: Colors.green),
                title: const Text('Pagar en el complejo', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Abonás el total cuando vas a jugar', style: TextStyle(color: Colors.white54)),
                onTap: () {
                  Navigator.pop(context); 
                  _confirmarReservaReal(); 
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.phone_android, color: Colors.blueAccent),
                title: const Text('Pagar con Mercado Pago', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Asegurá tu turno ahora mismo', style: TextStyle(color: Colors.white54)),
                onTap: () {
                  Navigator.pop(context); 
                  _procesarPagoMercadoPago(); 
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canchasProvider = context.watch<CanchasProvider>();
    final reservasProvider = context.watch<ReservasProvider>();

    return Scaffold(
      body: canchasProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(widget.facilityName),
                    background: Image.network(
                      widget.facilityImage,
                      fit: BoxFit.cover,
                      color: Colors.black54,
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Seleccioná la cancha:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCourtId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          items: canchasProvider.canchasDelComplejo.map((cancha) {
                            return DropdownMenuItem<String>(
                              value: cancha['id'].toString(),
                              child: Text(cancha['name'] ?? 'Cancha sin nombre'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCourtId = value;
                              _selectedScheduleId = null;
                              _selectedTimeLabel = null;
                            });
                            _consultarHorariosBackend();
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text('¿Qué día querés jugar?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _next7Days.length,
                            itemBuilder: (context, index) {
                              final date = _next7Days[index];
                              final isSelected = date.day == _selectedDate.day;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = date;
                                    _selectedScheduleId = null;
                                    _selectedTimeLabel = null;
                                  });
                                  _consultarHorariosBackend();
                                },
                                child: Container(
                                  width: 65,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.green : Colors.grey[850],
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: isSelected ? Colors.greenAccent : Colors.transparent),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_getDiaSemana(date.weekday), style: TextStyle(color: isSelected ? Colors.white : Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text('${date.day}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.white70)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Horarios disponibles:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        reservasProvider.isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.green))
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: reservasProvider.availableSchedules.map((horario) {
                                    final isOccupied = horario['occupied'] as bool? ?? false;
                                    final timeRaw = horario['start_time'] ?? '00:00:00';
                                    final timeLabel = timeRaw.length >= 5 ? timeRaw.substring(0, 5) : timeRaw;
                                    final scheduleId = horario['id'].toString();
                                    final isSelected = _selectedScheduleId == scheduleId;

                                  return InkWell(
                                    onTap: isOccupied
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedScheduleId = scheduleId;
                                              _selectedTimeLabel = timeLabel;
                                            });
                                          },
                                    child: Container(
                                      width: 100,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isOccupied
                                            ? Colors.red[900]!.withOpacity(0.4)
                                            : isSelected
                                                ? Colors.green
                                                : Colors.grey[800],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: isSelected ? Colors.white : Colors.transparent),
                                      ),
                                      child: Center(
                                        child: Text(
                                          isOccupied ? 'Ocupado' : timeLabel,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isOccupied ? Colors.red[200] : Colors.white,
                                            decoration: isOccupied ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              disabledBackgroundColor: Colors.grey[800],
                            ),
                            onPressed: _selectedScheduleId == null ? null : _confirmarReservaReal,
                            child: Text(
                              _selectedScheduleId == null ? 'Seleccioná un horario' : 'RESERVAR $_selectedTimeLabel專HS',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}