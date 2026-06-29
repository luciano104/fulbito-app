import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/features/owner/screens/owner_dashboard_tab.dart';


class OwnerDashboardProvider extends ChangeNotifier {
  List<CourtStatus> courts = [];
  DashboardStats? stats;
  bool isLoading = true;
  String? errorMessage;

  Future<void> cargarDashboard(String token, int facilityId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final facilityRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/facilities/$facilityId/'),
        headers: {'Authorization': token},
      );

      final statsRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/facilities/$facilityId/dashboard/'),
        headers: {'Authorization': token},
      );

      if (facilityRes.statusCode == 200 && statsRes.statusCode == 200) {
        final facilityData = json.decode(facilityRes.body);
        final statsData = json.decode(statsRes.body);

        courts = (facilityData['courts'] as List)
            .map((c) => CourtStatus.fromJson(c))
            .toList();

        stats = DashboardStats(
          turnosHoy: statsData['turnos_hoy'],
          porcentajeOcupacion: (statsData['porcentaje_ocupacion'] as num).toDouble(),
          ingresosEstimados: (statsData['ingresos_estimados'] as num).toDouble(),
          avgRating: (statsData['avg_rating'] as num).toDouble(),
          totalReviews: statsData['total_reviews'],
        );
      } else {
        errorMessage = 'Error al cargar el dashboard';
      }
    } catch (e) {
      errorMessage = 'Error de conexión: $e';
      print('Error en OwnerDashboardProvider: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDisponibilidad(String token, int courtId) async {
    try {
      final res = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/courts/$courtId/availability/'),
        headers: {'Authorization': token},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final index = courts.indexWhere((c) => c.id == courtId);
        if (index != -1) {
          courts[index].available = data['available'];
          notifyListeners();
        }
      }
    } catch (e) {
      errorMessage = 'Error al cambiar disponibilidad: $e';
      print('Error en toggleDisponibilidad: $e');
      notifyListeners();
    }
  }
}