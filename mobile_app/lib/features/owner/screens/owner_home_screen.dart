import 'package:flutter/material.dart';
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
  // Variable para saber qué pestaña está seleccionada (0, 1 o 2)
  int _currentIndex = 0;

  late final List<Widget> _paginas;

  @override
  void initState(){
    super.initState();
    //Pasamos token y facilityId a cada tab
    _paginas = [
      OwnerDashboardTab(token: widget.token, facilityId: widget.facilityId),
      OwnerBookingsTab(token: widget.token, facilityId: widget.facilityId),
      OwnerGridTab(token: widget.token, facilityId: widget.facilityId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El AppBar puede cambiar su título dinámicamente según la pestaña activa
      appBar: AppBar(
        title: Text(_obtenerTituloBarra(_currentIndex)),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false, // Oculta el botón de volver (ya que es un Home)
      ),
      
      // Muestra la pantalla correspondiente al índice actual
      body: _paginas[_currentIndex],

      // La barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green, // Color del ícono seleccionado
        unselectedItemColor: Colors.grey, // Color de los íconos no seleccionados
        type: BottomNavigationBarType.fixed, // Mantiene los nombres fijos siempre
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

  // Función auxiliar para cambiar el título de la AppCommerce según la pestaña
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