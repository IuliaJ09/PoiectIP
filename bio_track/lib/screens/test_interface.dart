import 'package:flutter/material.dart';
import 'calendar_screen copy.dart';
import 'parameters_screen copy.dart';
import 'alerts_screen copy.dart';
import 'recommendations_screen copy.dart';
import '../screens/login_screen.dart'; 


class TestInterface extends StatefulWidget {
  @override
  _TestInterfaceState createState() => _TestInterfaceState();
}

class _TestInterfaceState extends State<TestInterface> {
  int _currentIndex = 0;

  final screens = [
    ParametersScreenTest(),
    AlertsScreenTest(),
    RecommendationsScreenTest(),
    CalendarScreenTest(),
  ];

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BioTrack'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Parametri'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alerte'),
          BottomNavigationBarItem(icon: Icon(Icons.recommend), label: 'Recomandări'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
