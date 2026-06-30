import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/features/owner/providers/owner_grid_provider.dart';

// ─────────────────────────────────────────────
//  MODELOS
// ─────────────────────────────────────────────

class GridCell {
  final int? scheduleId;
  final int courtId;
  final String startTime;
  final String endTime;
  final bool available;
  final bool occupied;
  final bool passed;

  GridCell({
    this.scheduleId,
    required this.courtId,
    required this.startTime,
    required this.endTime,
    required this.available,
    required this.occupied,
    required this.passed,
  });

  String get estado {
    if (!available) return 'mantenimiento';
    if (passed && occupied) return 'finalizado_reservado';
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
//  COLORES Y LABELS POR ESTADO
// ─────────────────────────────────────────────

Color _bgColor(String estado) {
  switch (estado) {
    case 'reservado':            return Colors.red.shade100;
    case 'finalizado_reservado': return Colors.purple.shade100;
    case 'finalizado':           return Colors.grey.shade300;
    case 'mantenimiento':        return Colors.orange.shade100;
    default:                     return Colors.green.shade100;
  }
}

Color _textColor(String estado) {
  switch (estado) {
    case 'reservado':            return Colors.red.shade900;
    case 'finalizado_reservado': return Colors.purple.shade900;
    case 'finalizado':           return Colors.grey.shade600;
    case 'mantenimiento':        return Colors.orange.shade900;
    default:                     return Colors.green.shade900;
  }
}

String _estadoLabel(String estado) {
  switch (estado) {
    case 'reservado':            return 'Reservado';
    case 'finalizado_reservado': return 'Completado';
    case 'finalizado':           return 'Sin reserva';
    case 'mantenimiento':        return 'Mantenim.';
    default:                     return 'Libre';
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
  void _dialogoNuevaCancha(OwnerGridProvider provider) {
    String teamSize = 'F5';
    String surface = 'turf';
    final priceController = TextEditingController();
    const superficies = {
      'grass': 'Pasto Natural',
      'turf': 'Pasto Sintético',
      'concrete': 'Cemento',
      'dirt': 'Tierra',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Cancha'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: teamSize,
                decoration: const InputDecoration(labelText: 'Tamaño de equipo'),
                items: ['F5', 'F7', 'F11'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => teamSize = val ?? teamSize,
              ),
              DropdownButtonFormField<String>(
                value: surface,
                decoration: const InputDecoration(labelText: 'Superficie'),
                items: superficies.entries.map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      )).toList(),
                onChanged: (val) => surface = val ?? surface,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Precio por hora \$'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final price = double.tryParse(priceController.text) ?? 0.0;
              final ok = await provider.agregarCancha(widget.token, widget.facilityId, teamSize, surface, price);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Cancha creada. Se copiaron los horarios base.' : 'Error al crear cancha')),
                );
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _dialogoNuevoHorario(OwnerGridProvider provider) {
    final startController = TextEditingController(text: '22:00:00');
    final endController = TextEditingController(text: '23:00:00');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Horario Global'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Se añadirá a todas las canchas de tu complejo.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startController,
              decoration: const InputDecoration(labelText: 'Hora de Inicio (HH:MM:SS)'),
            ),
            TextField(
              controller: endController,
              decoration: const InputDecoration(labelText: 'Hora de Fin (HH:MM:SS)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final ok = await provider.agregarHorarioGlobal(widget.token, widget.facilityId, startController.text, endController.text);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Rango horario agregado exitosamente' : 'Error al añadir el horario')),
                );
              }
            },
            child: const Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Dialogo para modificar atributos, dar mantenimiento o eliminar la cancha
  void _dialogoEditarCancha(OwnerGridProvider provider, Map<String, dynamic> court, int index) {
    String teamSize = court['team_size'] ?? 'F5';
    String surface = court['surface'] ?? 'turf';
    bool available = court['available'] ?? true;
    final priceController = TextEditingController(text: court['price'].toString());

    const superficies = {
      'grass': 'Pasto Natural',
      'turf': 'Pasto Sintético',
      'concrete': 'Cemento',
      'dirt': 'Tierra',
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Editar Cancha ${index + 1}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: teamSize,
                  decoration: const InputDecoration(labelText: 'Tamaño'),
                  items: ['F5', 'F7', 'F11'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => teamSize = val ?? teamSize,
                ),
                DropdownButtonFormField<String>(
                  value: surface,
                  decoration: const InputDecoration(labelText: 'Superficie'),
                  items: superficies.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  )).toList(),
                  onChanged: (val) => surface = val ?? surface,
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Precio \$'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Habilitada / Disponible'),
                  subtitle: const Text('Desmarcar si entra en mantenimiento'),
                  activeColor: Colors.green,
                  value: available,
                  onChanged: (val) => setDialogState(() => available = val),
                )
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                _confirmarEliminacion(provider, court, index);
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                    final datos = {
                      'team_size': teamSize,
                      'surface': surface,
                      'price': double.tryParse(priceController.text) ?? court['price'],
                      'available': available,
                    };
                    final ok = await provider.editarCancha(widget.token, widget.facilityId, court['id'], datos);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'Cancha actualizada' : 'Error al guardar cambios')),
                      );
                    }
                  },
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _confirmarEliminacion(OwnerGridProvider provider, Map<String, dynamic> court, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar Cancha ${index + 1}?'),
        content: const Text(
          'Esta acción no se puede deshacer. Se eliminarán permanentemente la cancha y todos sus horarios asociados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final ok = await provider.eliminarCancha(widget.token, widget.facilityId, court['id']);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Cancha eliminada correctamente.' : 'Error al intentar eliminar la cancha.'),
                    backgroundColor: ok ? Colors.black87 : Colors.red.shade800,
                  ),
                );
              }
            },
            child: const Text('Confirmar y Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _dialogoOpcionesTurno(OwnerGridProvider provider, GridCell cell, String hora, int courtIndex) {
    if (cell.scheduleId == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Turno de las $hora — Cancha ${courtIndex + 1}'),
        content: Text('Estado actual: ${cell.estado.toUpperCase()}\n\n¿Qué acción querés realizar sobre este bloque horario?'),
        actionsOverflowDirection: VerticalDirection.down,
        actions: [
          if (cell.estado == 'libre' || cell.estado == 'mantenimiento')
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar esta franja horaria'),
              onPressed: () async {
                Navigator.pop(context);
                _confirmarEliminarHorario(provider, cell.scheduleId!, hora, courtIndex);
              },
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarHorario(OwnerGridProvider provider, int scheduleId, String hora, int courtIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Horario?'),
        content: Text('¿Seguro que querés quitar el horario de las $hora de la Cancha ${courtIndex + 1}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final errorMsg = await provider.eliminarHorario(widget.token, widget.facilityId, scheduleId);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMsg ?? 'Horario removido con éxito.'),
                    backgroundColor: errorMsg != null ? Colors.red.shade800 : Colors.black87,
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerGridProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_box, size: 18, color: Colors.white),
                  label: const Text('Nueva Cancha', style: TextStyle(fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                  onPressed: () => _dialogoNuevaCancha(provider),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.more_time, size: 18, color: Colors.white),
                  label: const Text('Nuevo Horario', style: TextStyle(fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade700),
                  onPressed: () => _dialogoNuevoHorario(provider),
                ),
              ),
            ],
          ),
        ),

        // ── SELECTOR DE FECHA ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _leyendaItem(Colors.green.shade100, Colors.green.shade900, 'Libre'),
              _leyendaItem(Colors.red.shade100, Colors.red.shade900, 'Reservado'),
              _leyendaItem(Colors.purple.shade100, Colors.purple.shade900, 'Completado'),
              _leyendaItem(Colors.grey.shade300, Colors.grey.shade600, 'Sin reserva'),
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
              const SizedBox(width: 40),
              ...provider.rawCourts.asMap().entries.map((entry) {
                int index = entry.key;
                var court = entry.value;
                String displayTitle = provider.courtNames[index];

                return Expanded(
                  child: InkWell(
                    onTap: () => _dialogoEditarCancha(provider, court, index),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                      decoration: BoxDecoration(
                        color: (court['available'] ?? true) ? Colors.green : Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1),)]
                      ),
                      child: Column(
                        children: [
                          Text(
                            displayTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                      ),
                          const SizedBox(height: 2),
                          const Icon(Icons.edit, size: 10, color: Colors.white70)
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 6),

          // ── FILAS de horarios ──
          ...provider.grilla.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        row.hora,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ...row.cells.asMap().entries.map((entry) {
                      int cellIndex = entry.key;
                      var cell = entry.value;
                      final estado = cell.estado;
                      return Expanded(
                        child: InkWell(
                          onTap: () => _dialogoOpcionesTurno(provider, cell, row.hora, cellIndex),
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
                        )
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
      mainAxisSize: MainAxisSize.min,
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