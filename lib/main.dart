import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vistas/login.dart';
import 'vistas/monedavista.dart';

void main() {
  runApp(const MonedasApp());
}

class MonedasApp extends StatelessWidget {
  const MonedasApp({super.key});

  Future<bool> _tieneSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monedas App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: _tieneSesion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == true) {
            return const MonedaVista();
          }
          return const Login();
        },
      ),
      routes: {
        "/login": (context) => const Login(),
        "/monedas": (context) => const MonedaVista(),
      },
    );
  }
}
