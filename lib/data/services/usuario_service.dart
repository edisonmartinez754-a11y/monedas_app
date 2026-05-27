import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';

class UsuarioService {
  final String baseUrl = "${ApiConfig.baseUrl}/usuarios";

  Future<bool> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/validar/$username/$password");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        final token = data["token"]?.toString() ?? '';
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

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
