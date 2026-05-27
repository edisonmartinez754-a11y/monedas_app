import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/moneda_page.dart';

void main() {
  runApp(const MonedasApp());
}

class MonedasApp extends StatelessWidget {
  const MonedasApp({super.key});

  Future<bool> _hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonedaPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder<bool>(
        future: _hasSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == true) {
            return const MonedaPage();
          }
          return const LoginPage();
        },
      ),
      routes: {
        "/login": (context) => const LoginPage(),
        "/monedas": (context) => const MonedaPage(),
      },
    );
  }
}
