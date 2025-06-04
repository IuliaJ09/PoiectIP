import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inițializare Supabase
  await Supabase.initialize(
    url: 'https://yqyhamgoeecfwyqgmhsd.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlxeWhhbWdvZWVjZnd5cWdtaHNkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgwMTI5OTAsImV4cCI6MjA2MzU4ODk5MH0.2N_rq9R_oFd-HlHm0ka980ZP7PwdlxepDkAS7ZKWkzQ',         
  );

  runApp(BioTrackApp());
}

class BioTrackApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey.shade700,
        ),
      ),
      home: LoginScreen(), // Ecranul de start
    );
  }
}
