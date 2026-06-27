import 'package:flutter/material.dart';
import 'package:mobile_app/features/owner/providers/owner_grid_provider.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────
//  MODELOS — exportados para el provider
// ─────────────────────────────────────────────
class GridCell {
  final int courtId;
  final String courtName;
  final String startTime;
  final String endTime;
  final bool available;
  final bool occupied;
  final String playerLabel;
 
  GridCell({
    required this.courtId,
    required this.courtName,
    required this.startTime,
    required this.endTime,
    required this.available,
    required this.occupied,
    required this.playerLabel,
  });
 
  String get estado {
    if (!available) return 'Mantenimiento';
    if (occupied) return 'Reservado';
    return 'Libre';
  }
}
 
class GridRow {
  final String hora;
  final List<GridCell> cells;
 
  GridRow({required this.hora, required this.cells});
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
  void initState(){
    super.initState();
    Future.microtask(() =>
      Provider.of<OwnerGridProvider>(context, listen: false)
        .cargarGrilla(widget.token, widget.facilityId));
  }

  Color _getColorPorEstado(String estado){
    switch (estado){
      case 'Reservado':
        return Colors.red.shade100;
      case 'Mantenimiento':
        return Colors.orange.shade100;
      default:
        return Colors.green.shade100;
    }
  }

  Color _getTextColorPorEstado(String estado){
    switch (estado) {
      case 'Reservado':
        return Colors.red.shade900;
      case 'Mantenimiento':
        return Colors.orange.shade900;
      default:
        return Colors.green.shade900;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerGridProvider>(context);
    
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

          if(provider.isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.green),)
          else if (provider.errorMessage != null)
            Center(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red),),)
          else if (provider.grilla.isEmpty)
            const Center(child: Text('No hay horarios cargados para hoy.', style: TextStyle(color: Colors.grey),),)
          else
            ...provider.grilla.map((bloque) => Card(
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
                            bloque.hora,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Grilla de las 3 canchas en paralelo
                      Row(
                        children: bloque.cells.asMap().entries.map((entry) {
                            final i = entry.key;
                            final cell = entry.value;
                            return Expanded(
                              child: Row(children: [
                                if (i > 0) const SizedBox(width: 8),
                                Expanded(child: _buildCanchaStatusBox(cell)),
                              ]),
                            );
                          }).toList(),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // --- WIDGET AUXILIAR: Arma el casillero de cada cancha individual ---
  Widget _buildCanchaStatusBox(GridCell cell) {
    final estado = cell.estado;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getColorPorEstado(estado),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: _getTextColorPorEstado(estado).withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(cell.courtName,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getTextColorPorEstado(estado))),
        const SizedBox(height: 4),
        Text(estado,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _getTextColorPorEstado(estado))),
        if (cell.playerLabel.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(cell.playerLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                  fontStyle: FontStyle.italic)),
        ],
      ]),
    );
  }
}