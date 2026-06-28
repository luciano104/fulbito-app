import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/auth/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  bool isLoading = false;
  String? errorMessage;

  Future<void> updateUser({
    required AuthProvider authProvider,
    required String name,
    required String lastname,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _userService.updateUser(
        userId: authProvider.user!.id,
        token: authProvider.token!,
        name: name,
        lastname: lastname,
      );

      // Actualizamos el usuario en el AuthProvider con los datos frescos del backend
      authProvider.user = AuthUser(
        id: response['user']['id'],
        name: response['user']['name'],
        lastname: response['user']['lastname'],
        email: response['user']['email'],
        role: response['user']['role'],
        facilityId: response['user']['facility_id'],
      );
      authProvider.notifyListeners();

    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}