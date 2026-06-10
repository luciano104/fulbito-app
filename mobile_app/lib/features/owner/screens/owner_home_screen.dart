import 'package:flutter/material.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  // Variable para saber qué pestaña está seleccionada (0, 1 o 2)
  int _currentIndex = 0;

  // Lista de las 3 pantallas que corresponden a cada pestaña
  // Por ahora ponemos contenedores simples con texto para probar la navegación
  final List<Widget> _paginas = [
    const Center(child: Text('Pestaña 1: Mi Complejo y Reputación', style: TextStyle(fontSize: 18))),
    const Center(child: Text('Pestaña 2: Gestión de Reservas y Feedback', style: TextStyle(fontSize: 18))),
    const Center(child: Text('Pestaña 3: Grilla Horaria Global', style: TextStyle(fontSize: 18))),
  ];

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
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Cambia la pestaña activa al hacer tap
          });
        },
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
        return 'Complejo App';
    }
  }
}