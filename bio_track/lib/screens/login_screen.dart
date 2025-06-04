import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart'; // ecranul după autentificare
import 'test_interface.dart'; // ecranul local de test

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  void _login() async {
    final cnp = emailController.text.trim();
    final password = passwordController.text.trim();

    // Caz de test local
    if (cnp == 'test' && password == 'test') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TestInterface()),
      );
      return;
    }

    // Caz Supabase
    setState(() {
    isLoading = true;
    errorMessage = '';
  });

  try {
    final response = await Supabase.instance.client
        .from('pacient')
        .select()
        .eq('cnp', int.parse(cnp))
        .eq('parola', password)
        .maybeSingle();

    if (response != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(cnp: cnp)),
      );
    } else {
      setState(() {
        errorMessage = 'CNP sau parolă incorecte';
      });
    }
  } catch (e) {
      setState(() {
        errorMessage = 'Eroare la conectare: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Autentificare')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'CNP'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Parolă'),
            ),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text('Autentificare'),
            ),
          ],
        ),
      ),
    );
  }
}
