import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/providers/user_provider.dart';
import 'core/constants/app_constants.dart';
//SCREENS
import 'package:mobile_app/features/auth/screens/login_screen.dart';
import 'package:mobile_app/features/auth/screens/register_screen.dart';
import 'package:mobile_app/features/player/screens/navigation_bar.dart';
// PROVIDERS
import 'package:provider/provider.dart';
// AUTH
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
// JUGADOR
import 'features/player/providers/canchas_provider.dart'; 
import 'features/player/providers/reservas_provider.dart';
// DUEÑO
import 'features/owner/providers/owner_bookings_provider.dart';
import 'features/owner/providers/owner_dashboard_provider.dart';
import 'features/owner/providers/owner_grid_provider.dart';

void main() {
  runApp(const CanchasSaltaApp());
}

class CanchasSaltaApp extends StatelessWidget {
  const CanchasSaltaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Envolvemos todo en MultiProvider
    return MultiProvider(
      providers: [
        // Auth
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Jugador
        ChangeNotifierProvider(create: (_) => CanchasProvider()),
        ChangeNotifierProvider(create: (_) => ReservasProvider()),
        // Dueño
        ChangeNotifierProvider(create: (_) => OwnerDashboardProvider()),
        ChangeNotifierProvider(create: (_) => OwnerBookingsProvider()),
        ChangeNotifierProvider(create: (_) => OwnerGridProvider()),
      ],
      child: MaterialApp(
        title: 'Fulbito App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00C853),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
        ),
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login:      (_) => const LoginScreen(),
          AppRoutes.register:   (_) => const RegisterScreen(),
          AppRoutes.playerHome: (_) => const JugadorHomeScreen(),
        },
      ),
    );
  }
}