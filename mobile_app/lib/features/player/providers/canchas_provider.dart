import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/features/player/screens/home_screen.dart'; // Ajustá el import a tu ruta real

class CanchasProvider extends ChangeNotifier {
  List<CanchaFeed> canchas = [];
  bool isLoading = true;

  Future<void> obtenerCanchas() async {
    final url = Uri.parse('http://127.0.0.1:8000/list_facilities/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final List<dynamic> facilitiesData = decodedData['facilities'] ?? [];
        canchas = facilitiesData.map((data) => CanchaFeed.fromJson(data)).toList();
      } else {
        print('Error de servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión en CanchasProvider: $e');
    } finally {
      isLoading = false;
      notifyListeners(); // ¡Avisa a las pantallas que se redibujen con los datos nuevos!
    }
  }

  void toggleFavorito(int index) {
    canchas[index].esFavorita = !canchas[index].esFavorita;
    canchas.sort((a, b) {
      if (a.esFavorita && !b.esFavorita) return -1;
      if (!a.esFavorita && b.esFavorita) return 1;
      return 0;
    });
    notifyListeners(); // Avisa el cambio de color del corazón
  }
}