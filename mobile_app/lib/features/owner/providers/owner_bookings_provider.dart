import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/features/owner/screens/owner_bookings_tab.dart';

class OwnerBookingsProvider extends ChangeNotifier {
  List<OwnerReservation> reservations = [];
  List<OwnerReview> reviews = [];
  bool isLoading = true;
  String? errorMessage;

  List<OwnerReservation> get pendingReservations =>
      reservations.where((r) => r.isPending).toList();

  Future<void> cargarReservas(String token, int facilityId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final reservationsRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/facilities/$facilityId/reservations/'),
        headers: {'Authorization': token},
      );

      final facilityRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/facilities/$facilityId/'),
        headers: {'Authorization': token},
      );

      if (reservationsRes.statusCode == 200 && facilityRes.statusCode == 200) {
        final reservationsData = json.decode(reservationsRes.body);
        final facilityData = json.decode(facilityRes.body);

        reservations = (reservationsData['reservations'] as List)
            .map((r) => OwnerReservation.fromJson(r))
            .toList();

        reviews = (facilityData['reviews'] as List)
            .map((r) => OwnerReview.fromJson(r))
            .toList();
      } else {
        errorMessage = 'Error al cargar las reservas';
      }
    } catch (e) {
      errorMessage = 'Error de conexión: $e';
      print('Error en OwnerBookingsProvider: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmar(String token, int reservationId) async {
    await _cambiarEstado(token, reservationId, 'confirmed');
  }

  Future<void> rechazar(String token, int reservationId) async {
    await _cambiarEstado(token, reservationId, 'canceled');
  }

  Future<void> _cambiarEstado(
      String token, int reservationId, String nuevoEstado) async {
    try {
      final res = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/reservations/$reservationId/status/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': nuevoEstado}),
      );

      if (res.statusCode == 200) {
        final index = reservations.indexWhere((r) => r.id == reservationId);
        if (index != -1) {
          reservations[index].status = nuevoEstado;
          notifyListeners();
        }
      } else {
        errorMessage = 'Error al actualizar la reserva';
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Error de conexión: $e';
      print('Error en _cambiarEstado: $e');
      notifyListeners();
    }
  }
}