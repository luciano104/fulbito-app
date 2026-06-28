import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/app_constants.dart';

class UserService {
  Future<Map<String, dynamic>> updateUser({
    required int userId,
    required String token,
    required String name,
    required String lastname,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/user/$userId/update/'),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'lastname': lastname,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Error al actualizar el perfil');
  }
}