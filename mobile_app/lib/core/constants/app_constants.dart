/// Roles de usuario definidos en el backend Django.
/// El login devuelve uno de estos strings en el campo 'role'.
class AppRoles {
  static const String player = 'jugador';
  static const String owner = 'dueno';
}

/// Nombres de rutas para la navegación.
/// Usar siempre estas constantes en lugar de strings sueltos.
class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String playerHome = '/jugador/home';
}

//URL base
class ApiConstants {
  static const String baseUrl = 'http://192.168.211.121:8000/api';
}