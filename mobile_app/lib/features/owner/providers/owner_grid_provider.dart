import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/features/auth/screens/owner_grid_tab.dart';


class OwnerGridProvider extends ChangeNotifier {
  List<GridRow> grilla = [];
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
      final courts =
          List<Map<String, dynamic>>.from(facilityData['courts']);

      // Requests en paralelo — uno por cancha
      final schedulesResponses = await Future.wait(
        courts.map((court) => http.get(
              Uri.parse(
                  '${ApiConstants.baseUrl}/courts/${court['id']}/schedules/?date=$_dateStr'),
              headers: {'Authorization': token},
            )),
      );

      // Mapa: startTime → { courtId → GridCell }
      final Map<String, Map<int, GridCell>> grillaMap = {};

      for (int i = 0; i < courts.length; i++) {
        final court = courts[i];
        final res = schedulesResponses[i];
        if (res.statusCode != 200) continue;

        final schedules = List<Map<String, dynamic>>.from(
            json.decode(res.body)['schedules']);

        for (final schedule in schedules) {
          final startTime = schedule['start_time'] as String;
          final endTime = schedule['end_time'] as String;

          grillaMap.putIfAbsent(startTime, () => {});
          grillaMap[startTime]![court['id']] = GridCell(
            courtId: court['id'],
            courtName: 'Cancha ${i + 1} - ${court['team_size']}',
            startTime: startTime.substring(0, 5),
            endTime: endTime.substring(0, 5),
            available: court['available'],
            occupied: schedule['occupied'] ?? false,
            playerLabel: '',
          );
        }
      }

      final sortedKeys = grillaMap.keys.toList()..sort();

      grilla = sortedKeys.map((key) {
        final cells = courts.map((court) {
          return grillaMap[key]![court['id']] ??
              GridCell(
                courtId: court['id'],
                courtName: court['team_size'],
                startTime: key.substring(0, 5),
                endTime: '',
                available: court['available'],
                occupied: false,
                playerLabel: '',
              );
        }).toList();

        return GridRow(
          hora: '${key.substring(0, 5)} - ${cells.first.endTime}',
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