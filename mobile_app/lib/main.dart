import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/screens/role_selector_screen.dart';
import 'features/player/screens/player_home_screen.dart';
import 'features/owner/screens/owner_home_screen.dart';

void main() {
  runApp(const CanchasSaltaApp());
}

class CanchasSaltaApp extends StatelessWidget {
  const CanchasSaltaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fulbito App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C853),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display', // fallback a la fuente del sistema
      ),

      // Pantalla inicial: selector de rol
      initialRoute: AppRoutes.roleSelector,

      // Tabla de rutas — agregar acá cada nueva pantalla
      routes: {
        AppRoutes.roleSelector: (_) => const RoleSelectorScreen(),
        AppRoutes.playerHome:  (_) => const JugadorHomeScreen(),
        AppRoutes.ownerHome:    (_) => const DuenoHomeScreen(),
      },
    );
  }
}