import 'package:flutter/material.dart';
import '/core/constants/app_constants.dart';

/// Pantalla de selección de rol.
///
/// TEMPORAL — reemplazar por el login real contra Django
/// cuando Luciano tenga los endpoints de autenticación listos.
///
/// Por ahora solo pregunta quién está probando la app
/// y redirige al flujo correspondiente.
class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Logo / ícono
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  color: Colors.white,
                  size: 36,
                ),
              ),

              const SizedBox(height: 28),

              // Título
              const Text(
                'Fulbito\nApp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),

              const Spacer(flex: 2),

              // Botón Jugador
              _RoleButton(
                label: 'Jugador',
                icon: Icons.person_outline,
                accentColor: const Color(0xFF00C853),
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.playerHome,
                ),
              ),

              const SizedBox(height: 16),

              // Botón Dueño
              _RoleButton(
                label: 'Dueño de Complejo',
                icon: Icons.storefront_outlined,
                accentColor: const Color(0xFF448AFF),
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.ownerHome,
                ),
              ),

              const Spacer(flex: 1),

              // Aviso temporal
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Modo desarrollo — sin base de datos',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGET INTERNO: botón de rol
// ─────────────────────────────────────────────
class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2C3D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: accentColor.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}