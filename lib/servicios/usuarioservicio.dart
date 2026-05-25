import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../configuracion/configuracionapi.dart';

class UsuarioServicio {
  final String urlBase = "${ConfiguracionApi.urlBase}/usuarios";

  Future<bool> validar(String usuario, String clave) async {
    final url = Uri.parse("$urlBase/validar/$usuario/$clave");

    try {
      final respuesta = await http.get(url).timeout(const Duration(seconds: 10));
      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        final token = datos["token"]?.toString() ?? '';
        if (token.isEmpty) {
          return false;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<bool> estaAutenticado() async {
    final token = await obtenerToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
