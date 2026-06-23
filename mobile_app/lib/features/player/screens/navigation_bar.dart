import 'package:flutter/material.dart';
import 'booking_screen.dart';
import 'home_screen.dart';
import 'canchas_map_screen.dart';

class JugadorHomeScreen extends StatefulWidget {
  const JugadorHomeScreen({super.key});

  @override
  State<JugadorHomeScreen> createState() => _JugadorHomeScreenState();
}

class _JugadorHomeScreenState extends State<JugadorHomeScreen> {
  
  int _selectedIndex = 0;

  
  final List<Widget> _screens = [
    const InicioTab(),
    const BookingsScreen(),
    const CanchasMapScreen(),
    
    const Center(
      child: Text('Cerca / Mapa\n(Próximamente)', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
    ),
  ];

 
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: _screens[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        
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