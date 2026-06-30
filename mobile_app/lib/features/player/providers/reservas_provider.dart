import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/app_constants.dart';
import 'dart:convert';
import '/features/player/screens/booking_screen.dart';

class ReservasProvider extends ChangeNotifier {
  List<ReservaActiva> misReservas = [];
  bool isLoading = true;
  List<dynamic> _horariosDisponibles = [];
  List<dynamic> get availableSchedules => _horariosDisponibles;

  Future<void> cargarHorariosDeCancha(String token, String courtId, String fechaFormateada) async {
    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/courts/$courtId/schedules/?date=$fechaFormateada');
      final response = await http.get(
        url,
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _horariosDisponibles = data['schedules'] ?? [];
      }
    } catch (e) {
      print('Error al cargar horarios: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> solicitarReserva(String token, String facilityId, String startTime, String fecha) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/reservations/create/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'facility_id': int.parse(facilityId),
          'start_time': '$startTime:00',
          'date': fecha,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error al solicitar reserva: $e');
      return false;
    }
  }
  
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
  Future<bool> enviarResena(String token, String reservaId, int rating, String comentario) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/reviews/create/'); 

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'reservation': reservaId, // ID de la reserva
          'rating': rating,         // Estrellas (1-5)
          'comment': comentario,    // Texto
        }),
      );

      if (response.statusCode == 201) {
        return true;
      }
      print('Error al enviar reseña: ${response.body}');
      return false;
    } catch (e) {
      print('Error de red al enviar reseña: $e');
      return false;
    }
  }
  Future<String?> crearPreferenciaPago(String token, String scheduleId, String fechaFormateada) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/reservations/create_payment/'); 

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token, 
        },
        body: jsonEncode({
          'schedule': scheduleId,
          'date': fechaFormateada,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['init_point']; 
      } else {
        print('Error del backend al crear pago: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error de red en Mercado Pago: $e');
      return null;
    }
  }
}