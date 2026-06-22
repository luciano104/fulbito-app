import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/features/player/screens/booking_screen.dart'; // Ajustá el import a tu ruta real

class ReservasProvider extends ChangeNotifier {
  List<ReservaActiva> misReservas = [];
  bool isLoading = true;

  Future<void> obtenerReservas() async {
    final url = Uri.parse('http://127.0.0.1:8000/my_reservations/');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
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