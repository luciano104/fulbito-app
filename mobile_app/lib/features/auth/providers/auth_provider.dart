import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/services/auth_service.dart';

class AuthUser {
  final int id;
  final String name;
  final String lastname;
  final String email;
  final String role;
  final int? facilityId; // solo lo tiene el dueño, null si es jugador

  AuthUser({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.role,
    this.facilityId,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'],
        name: json['name'],
        lastname: json['lastname'],
        email: json['email'],
        role: json['role'],
        facilityId: json['facility_id'], // Django lo agrega si es owner
      );

  bool get isOwner => role == 'owner';
  bool get isPlayer => role == 'player';
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  AuthUser? user;
  String? token;

  bool get isLogged => user != null;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _authService.login(
        email: email,
        password: password,
      );

      user = AuthUser.fromJson(response['user']);
      token = response['token'];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String lastname,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _authService.register(
        name: name,
        lastname: lastname,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      user = AuthUser.fromJson(response['user']);
      token = response['token'];
      
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    user = null;
    token = null;
    notifyListeners();
  }
}