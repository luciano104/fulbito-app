import 'package:flutter/material.dart';
import '/core/constants/app_constants.dart';

/// Pantalla de inicio del flujo Jugador.
/// RESPONSABLE: Walter
///
/// Esta pantalla es el punto de entrada del flujo del jugador.
/// Reemplazar el contenido con las pantallas reales.
class JugadorHomeScreen extends StatelessWidget {
  const JugadorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flujo Jugador',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 13,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Hola, Walter 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00C853).withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF00C853),
                      size: 22,
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 32),

              // Pantallas pendientes
              const Text(
                'Pantallas a desarrollar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              _PendingItem(
                label: 'Home — Lista de complejos y favoritos',
                tab: 'Pestaña 1',
                accentColor: const Color(0xFF00C853),
              ),
              _PendingItem(
                label: 'Historial de reservas y reseñas',
                tab: 'Pestaña 2',
                accentColor: const Color(0xFF00C853),
              ),
              _PendingItem(
                label: 'Mapa con GPS y grilla horaria',
                tab: 'Pestaña 3',
                accentColor: const Color(0xFF00C853),
              ),

              const Spacer(),

              // Botón volver
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(
                    context, AppRoutes.roleSelector),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2C3D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Cambiar de perfil',
                      style: TextStyle(
                        color: Colors.white60,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingItem extends StatelessWidget {
  final String label;
  final String tab;
  final Color accentColor;

  const _PendingItem({
    required this.label,
    required this.tab,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2C3D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tab,
              style: TextStyle(
                color: accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}