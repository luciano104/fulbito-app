import 'package:flutter/material.dart';
// import '../../core/constants/app_constants.dart'; // Descomentá y ajustá los '..' según la profundidad de tu carpeta

class JugadorHomeScreen extends StatefulWidget {
  const JugadorHomeScreen({super.key});

  @override
  State<JugadorHomeScreen> createState() => _JugadorHomeScreenState();
}

class _JugadorHomeScreenState extends State<JugadorHomeScreen> {
  // Variable para controlar qué pestaña está activa
  int _selectedIndex = 0;

  // Lista de pantallas "vacías" con los carteles de próximamente
  final List<Widget> _screens = [
    const Center(
      child: Text('Inicio\n(Próximamente)', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
    ),
    const Center(
      child: Text('Reservas\n(Próximamente)', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
    ),
    const Center(
      child: Text('Cerca / Mapa\n(Próximamente)', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
    ),
  ];

  // Función que se ejecuta al tocar un ícono
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Jugador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        // Usamos el color directamente acá para asegurarnos de que quede con el azul oscuro que querían
        backgroundColor: const Color(0xFF1A237E), 
        centerTitle: true,
      ),
      // Muestra el cartel que corresponda
      body: _screens[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Verde para el seleccionado
        selectedItemColor: const Color(0xFF00C853), 
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Cerca'),
        ],
      ),
    );
  }
}