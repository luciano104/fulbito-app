import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/features/owner/screens/owner_grid_tab.dart';

class OwnerGridProvider extends ChangeNotifier {
  List<GridRow> grilla = [];
  List<String> courtNames = [];
  List<Map<String, dynamic>> rawCourts = [];
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
      rawCourts = List<Map<String, dynamic>>.from(facilityData['courts']);

      if (rawCourts.isEmpty) {
        grilla = [];
        courtNames = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      courtNames = rawCourts
          .asMap()
          .entries
          .map((e) => 'Cancha ${e.key + 1} · ${e.value['team_size']}')
          .toList();

      final schedulesResponses = await Future.wait(
        rawCourts.map((court) => http.get(
              Uri.parse('${ApiConstants.baseUrl}/courts/${court['id']}/schedules/?date=$_dateStr&show_all=true'),
              headers: {'Authorization': token},
            )),
      );

      final Map<String, List<GridCell?>> grillaMap = {};

      for (int i = 0; i < rawCourts.length; i++) {
        final court = rawCourts[i];
        final res = schedulesResponses[i];
        if (res.statusCode != 200) continue;

        final schedules = List<Map<String, dynamic>>.from(
            json.decode(res.body)['schedules']);

        for (final s in schedules) {
          final key = s['start_time'] as String;
          grillaMap.putIfAbsent(key, () => List.filled(rawCourts.length, null));

          grillaMap[key]![i] = GridCell(
            scheduleId: s['id'],
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
        final cells = List<GridCell>.generate(rawCourts.length, (i) {
          return grillaMap[key]![i] ??
              GridCell(
                courtId: rawCourts[i]['id'],
                startTime: key.substring(0, 5),
                endTime: '',
                available: rawCourts[i]['available'] as bool,
                occupied: false,
                passed: false,
              );
        });

        final startDisplay = key.substring(0, 5);

        return GridRow(
          hora: startDisplay,
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

  Future<bool> agregarCancha(String token, int facilityId, String teamSize, String surface, double price) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/facilities/$facilityId/courts/create/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'team_size': teamSize,
          'surface': surface,
          'price': price,
          'available': true,
        }),
      );

      if (response.statusCode == 201) {
        await cargarGrilla(token, facilityId);
        return true;
      }
    } catch (e) {
      print('Error al agregar cancha: $e');
    }
    return false;
  }

  Future<bool> agregarHorarioGlobal(String token, int facilityId, String startTime, String endTime) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/facilities/$facilityId/schedules/add/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'start_time': startTime,
          'end_time': endTime,
        }),
      );

      if (response.statusCode == 201) {
        await cargarGrilla(token, facilityId);
        return true;
      }
    } catch (e) {
      print('Error al agregar horario global: $e');
    }
    return false;
  }

  Future<bool> editarCancha(String token, int facilityId, int courtId, Map<String, dynamic> datos) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/courts/$courtId/update/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode(datos),
      );

      if (response.statusCode == 200) {
        await cargarGrilla(token, facilityId);
        return true;
      }
    } catch (e) {
      print('Error al editar cancha: $e');
    }
    return false;
  }
  Future<bool> eliminarCancha(String token, int facilityId, int courtId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/courts/$courtId/delete/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 204 || response.statusCode == 200) {
        await cargarGrilla(token, facilityId);
        return true;
      }
    } catch (e) {
      print('Error al eliminar cancha: $e');
    }
    return false;
  }
  
  Future<String?> eliminarHorario(String token, int facilityId, int scheduleId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/schedules/$scheduleId/delete/'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 204) {
        await cargarGrilla(token, facilityId);
        return null;
      } else {
        final data = json.decode(response.body);
        return data['message'] ?? 'Error al eliminar el horario';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }
}