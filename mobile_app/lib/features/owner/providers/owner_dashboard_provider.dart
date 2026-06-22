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

      final reservationsRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/facilities/$facilityId/reservations/'),
        headers: {'Authorization': token},
      );

      if (facilityRes.statusCode == 200 && reservationsRes.statusCode == 200) {
        final facilityData = json.decode(facilityRes.body);
        final reservationsData = json.decode(reservationsRes.body);

        courts = (facilityData['courts'] as List)
            .map((c) => CourtStatus.fromJson(c))
            .toList();

        final today = DateTime.now();
        final todayStr =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

        final allReservations = (reservationsData['reservations'] as List);
        final confirmedToday = allReservations
            .where((r) => r['date'] == todayStr && r['status'] == 'confirmed')
            .toList();

        final totalSlots = courts.length * 12;
        final ocupacion =
            totalSlots > 0 ? (confirmedToday.length / totalSlots) * 100 : 0.0;

        double ingresos = 0;
        for (final _ in confirmedToday) {
          ingresos += double.tryParse(
                  facilityData['facility']['base_price'].toString()) ??
              0;
        }

        stats = DashboardStats(
          turnosHoy: confirmedToday.length,
          porcentajeOcupacion: ocupacion.toDouble(),
          ingresosEstimados: ingresos,
          avgRating:
              (facilityData['facility']['avg_rating'] as num).toDouble(),
          totalReviews: facilityData['facility']['total_reviews'],
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