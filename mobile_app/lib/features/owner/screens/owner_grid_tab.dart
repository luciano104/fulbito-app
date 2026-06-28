import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/features/owner/providers/owner_grid_provider.dart';

// ─────────────────────────────────────────────
//  MODELOS
// ─────────────────────────────────────────────

class GridCell {
  final int courtId;
  final String startTime;
  final String endTime;
  final bool available;
  final bool occupied;
  final bool passed;

  GridCell({
    required this.courtId,
    required this.startTime,
    required this.endTime,
    required this.available,
    required this.occupied,
    required this.passed,
  });

  String get estado {
    if (!available) return 'mantenimiento';
    if (passed) return 'finalizado';
    if (occupied) return 'reservado';
    return 'libre';
  }
}

class GridRow {
  final String hora;
  final List<GridCell> cells;
  GridRow({required this.hora, required this.cells});
}

// ─────────────────────────────────────────────
//  COLORES POR ESTADO
// ─────────────────────────────────────────────

Color _bgColor(String estado) {
  switch (estado) {
    case 'reservado':   return Colors.red.shade100;
    case 'finalizado':  return Colors.grey.shade300;
    case 'mantenimiento': return Colors.orange.shade100;
    default:            return Colors.green.shade100;
  }
}

Color _textColor(String estado) {
  switch (estado) {
    case 'reservado':   return Colors.red.shade900;
    case 'finalizado':  return Colors.grey.shade600;
    case 'mantenimiento': return Colors.orange.shade900;
    default:            return Colors.green.shade900;
  }
}

String _estadoLabel(String estado) {
  switch (estado) {
    case 'reservado':     return 'Reservado';
    case 'finalizado':    return 'Finalizado';
    case 'mantenimiento': return 'Mantenim.';
    default:              return 'Libre';
  }
}

// ─────────────────────────────────────────────
//  PANTALLA
// ─────────────────────────────────────────────

class OwnerGridTab extends StatefulWidget {
  final String token;
  final int facilityId;

  const OwnerGridTab({
    super.key,
    required this.token,
    required this.facilityId,
  });

  @override
  State<OwnerGridTab> createState() => _OwnerGridTabState();
}

class _OwnerGridTabState extends State<OwnerGridTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<OwnerGridProvider>(context, listen: false)
            .cargarGrilla(widget.token, widget.facilityId));
  }

  Future<void> _elegirFecha(OwnerGridProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.green),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      await provider.cambiarFecha(widget.token, widget.facilityId, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerGridProvider>(context);

    return Column(
      children: [
        // ── SELECTOR DE FECHA ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.green.withOpacity(0.05),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Text(
                _formatFecha(provider.selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _elegirFecha(provider),
                child: const Text('Cambiar fecha',
                    style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ),

        // ── LEYENDA ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _leyendaItem(Colors.green.shade100, Colors.green.shade900, 'Libre'),
              _leyendaItem(Colors.red.shade100, Colors.red.shade900, 'Reservado'),
              _leyendaItem(Colors.grey.shade300, Colors.grey.shade600, 'Finalizado'),
              _leyendaItem(Colors.orange.shade100, Colors.orange.shade900, 'Mantenim.'),
            ],
          ),
        ),

        const Divider(height: 1),

        // ── CONTENIDO ──
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.green))
              : provider.errorMessage != null
                  ? Center(
                      child: Text(provider.errorMessage!,
                          style: const TextStyle(color: Colors.red)))
                  : provider.grilla.isEmpty
                      ? const Center(
                          child: Text('No hay horarios para este día.',
                              style: TextStyle(color: Colors.grey)))
                      : _buildTabla(provider),
        ),
      ],
    );
  }

  Widget _buildTabla(OwnerGridProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // ── HEADER con nombres de canchas ──
          Row(
            children: [
              // Columna de horas — ancho fijo
              const SizedBox(width: 72),
              ...provider.courtNames.map((name) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 6),

          // ── FILAS de horarios ──
          ...provider.grilla.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    // Hora a la izquierda
                    SizedBox(
                      width: 72,
                      child: Text(
                        row.hora,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Celda por cancha
                    ...row.cells.map((cell) {
                      final estado = cell.estado;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _bgColor(estado),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: _textColor(estado).withOpacity(0.25)),
                          ),
                          child: Text(
                            _estadoLabel(estado),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _textColor(estado),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _leyendaItem(Color bg, Color text, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: text.withOpacity(0.3)),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: text)),
      ],
    );
  }

  String _formatFecha(DateTime date) {
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${dias[date.weekday - 1]} ${date.day} ${meses[date.month - 1]} ${date.year}';
  }
}