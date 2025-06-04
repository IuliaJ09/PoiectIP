import 'package:bio_track/screens/feedback_history_screen.dart';
import 'package:flutter/material.dart';
import 'parameters_screen.dart';
import 'alerts_screen.dart';
import 'recommendations_screen.dart';
import 'calendar_screen.dart';
import 'feedback_screen.dart';
import '../screens/login_screen.dart'; 

class HomeScreen extends StatefulWidget {
  final String cnp;
  HomeScreen({required this.cnp});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ParametersScreen(cnp: widget.cnp),
      AlertsScreen(cnp: widget.cnp),
      RecommendationScreen(cnp: widget.cnp),
      CalendarScreen(cnp: widget.cnp),
      FeedbackScreen(cnp: widget.cnp),
      FeedbackHistoryScreen(cnp: widget.cnp)
    ];
  }

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
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey.shade700,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Parametri'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alerte'),
          BottomNavigationBarItem(icon: Icon(Icons.thumb_up), label: 'Recomandări'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Feedback'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Feedbackuri'),
        ],
      ),
    );
  }
}
