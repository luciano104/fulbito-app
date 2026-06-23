import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/app_constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Error al iniciar sesión');
  }

  Future<void> register({
    required String name,
    required String lastname,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'lastname': lastname,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode != 201) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Error al registrarse');
    }
  }
}