import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/app_constants.dart';
import 'dart:convert';
import '/features/player/screens/booking_screen.dart';

class ReservasProvider extends ChangeNotifier {
  List<ReservaActiva> misReservas = [];
  bool isLoading = true;

  Future<void> obtenerReservas(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/reservations/my_reservations/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final List<dynamic> reservationsData = decodedData['reservations'] ?? [];
        misReservas = reservationsData.map((data) => ReservaActiva.fromJson(data)).toList();
      }
    } catch (e) {
      print('Error de conexión en ReservasProvider: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}