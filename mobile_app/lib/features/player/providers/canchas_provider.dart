import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/features/player/screens/home_screen.dart'; 
import 'package:mobile_app/core/constants/app_constants.dart';

class CanchasProvider extends ChangeNotifier {
  List<CanchaFeed> canchas = [];
  bool isLoading = true;
  List<dynamic> _canchasDelComplejo = [];
  List<dynamic> get canchasDelComplejo => _canchasDelComplejo;

  
  Future<void> cargarDetallesDelComplejo(String token, String facilityId) async {
    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/facilities/$facilityId/'); 
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token, 
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _canchasDelComplejo = data['courts'] ?? [];
      } else {
        print('Error al cargar detalles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión en cargarDetallesDelComplejo: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> obtenerCanchas() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/facilities/');
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
      notifyListeners(); 
    }
  }

  void toggleFavorito(int index) {
    canchas[index].esFavorita = !canchas[index].esFavorita;
    canchas.sort((a, b) {
      if (a.esFavorita && !b.esFavorita) return -1;
      if (!a.esFavorita && b.esFavorita) return 1;
      return 0;
    });
    notifyListeners(); 
  }
}