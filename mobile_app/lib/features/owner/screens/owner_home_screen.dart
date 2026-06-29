import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/screens/profile_screen.dart';
import 'package:mobile_app/features/owner/screens/owner_grid_tab.dart';
import 'package:mobile_app/features/owner/screens/owner_bookings_tab.dart';
import 'package:mobile_app/features/owner/screens/owner_dashboard_tab.dart';

class OwnerHomeScreen extends StatefulWidget {
  final String token;
  final int facilityId;

  const OwnerHomeScreen({
    super.key,
    required this.token,
    required this.facilityId,
    });

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _paginas;

  @override
  void initState(){
    super.initState();
    _paginas = [
      OwnerDashboardTab(token: widget.token, facilityId: widget.facilityId),
      OwnerBookingsTab(token: widget.token, facilityId: widget.facilityId),
      OwnerGridTab(token: widget.token, facilityId: widget.facilityId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 3
          ? null
          : AppBar(
              title: Text(_obtenerTituloBarra(_currentIndex)),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () => setState(() => _currentIndex = 3),
              ),
            ),
      body: _currentIndex == 3
          ? ProfileScreen(onBack: () => setState(() => _currentIndex = 0))
          : _paginas[_currentIndex],
      bottomNavigationBar: _currentIndex == 3
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics),
                  label: 'Mi Complejo',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_soccer),
                  label: 'Reservas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: 'Grilla Horaria',
                ),
              ],
            ),
    );
  }

  String _obtenerTituloBarra(int index) {
    switch (index) {
      case 0:
        return 'Panel de Control';
      case 1:
        return 'Gestión de Solicitudes';
      case 2:
        return 'Matriz Horaria';
      default:
        return 'FulbitoApp';
    }
  }
}