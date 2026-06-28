import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/features/owner/screens/owner_grid_tab.dart';

class OwnerGridProvider extends ChangeNotifier {
  List<GridRow> grilla = [];
  List<String> courtNames = [];
  bool isLoading = true;
  String? errorMessage;
  DateTime selectedDate = DateTime.now();

  String get _dateStr {
    final d = selectedDate;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> cargarGrilla(String token, int facilityId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final facilityRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/facilities/$facilityId/'),
        headers: {'Authorization': token},
      );

      if (facilityRes.statusCode != 200) {
        errorMessage = 'Error al cargar las canchas';
        isLoading = false;
        notifyListeners();
        return;
      }

      final facilityData = json.decode(facilityRes.body);
      final courts = List<Map<String, dynamic>>.from(facilityData['courts']);

      if (courts.isEmpty) {
        grilla = [];
        courtNames = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      courtNames = courts
          .asMap()
          .entries
          .map((e) => 'Cancha ${e.key + 1} · ${e.value['team_size']}')
          .toList();

      final schedulesResponses = await Future.wait(
        courts.map((court) => http.get(
              Uri.parse(
                  '${ApiConstants.baseUrl}/courts/${court['id']}/schedules/?date=$_dateStr'),
              headers: {'Authorization': token},
            )),
      );

      final Map<String, List<GridCell?>> grillaMap = {};

      for (int i = 0; i < courts.length; i++) {
        final court = courts[i];
        final res = schedulesResponses[i];
        if (res.statusCode != 200) continue;

        final schedules = List<Map<String, dynamic>>.from(
            json.decode(res.body)['schedules']);

        for (final s in schedules) {
          final key = s['start_time'] as String;
          grillaMap.putIfAbsent(key, () => List.filled(courts.length, null));

          grillaMap[key]![i] = GridCell(
            courtId: court['id'],
            startTime: (s['start_time'] as String).substring(0, 5),
            endTime: (s['end_time'] as String).substring(0, 5),
            available: court['available'] as bool,
            occupied: s['occupied'] as bool? ?? false,
            passed: s['passed'] as bool? ?? false,
          );
        }
      }

      final sortedKeys = grillaMap.keys.toList()..sort();

      grilla = sortedKeys.map((key) {
        final cells = List<GridCell>.generate(courts.length, (i) {
          return grillaMap[key]![i] ??
              GridCell(
                courtId: courts[i]['id'],
                startTime: key.substring(0, 5),
                endTime: '',
                available: courts[i]['available'] as bool,
                occupied: false,
                passed: false,
              );
        });

        final startDisplay = key.substring(0, 5);
        final endDisplay = cells.first.endTime;

        return GridRow(
          hora: '$startDisplay - $endDisplay',
          cells: cells,
        );
      }).toList();
    } catch (e) {
      errorMessage = 'Error de conexión: $e';
      print('Error en OwnerGridProvider: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cambiarFecha(
      String token, int facilityId, DateTime nuevaFecha) async {
    selectedDate = nuevaFecha;
    await cargarGrilla(token, facilityId);
  }
}