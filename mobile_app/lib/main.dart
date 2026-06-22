import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. Importamos Provider
import 'core/constants/app_constants.dart';
import 'features/auth/screens/role_selector_screen.dart';
import 'features/player/screens/navigation_bar.dart';
import 'features/owner/screens/owner_home_screen.dart';
// Importá tus providers creados en el Paso 2
import 'features/player/providers/canchas_provider.dart'; 
import 'features/player/providers/reservas_provider.dart';

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
        ChangeNotifierProvider(create: (_) => CanchasProvider()),
        ChangeNotifierProvider(create: (_) => ReservasProvider()),
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
        initialRoute: AppRoutes.roleSelector,
        routes: {
          AppRoutes.roleSelector: (_) => const RoleSelectorScreen(),
          AppRoutes.playerHome:  (_) => const JugadorHomeScreen(),
          AppRoutes.ownerHome:    (_) => const OwnerHomeScreen(),
        },
      ),
    );
  }
}