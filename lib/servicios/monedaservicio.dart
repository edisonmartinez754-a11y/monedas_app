import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../configuracion/configuracionapi.dart';
import '../modelos/moneda.dart';

class MonedaServicio {
  final String urlBase = "${ConfiguracionApi.urlBase}/monedas";

  Future<Map<String, String>> _getEncabezado() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null || token.isEmpty) {
      throw Exception('Sesión no iniciada. Inicie sesión nuevamente.');
    }
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  Future<List<Moneda>> listar() async {
    final url = Uri.parse("$urlBase/listar");
    try {
      final encabezado = await _getEncabezado();
      final respuesta = await http.get(url, headers: encabezado).timeout(const Duration(seconds: 10));
      if (respuesta.statusCode == 200) {
        return Moneda.desdeListaJson(jsonDecode(respuesta.body));
      }
      if (respuesta.statusCode == 401) {
        throw Exception('Sesión inválida. Inicie sesión nuevamente.');
      }
      throw Exception('Error cargando monedas: ${respuesta.statusCode}');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<CambioMoneda>> listarPorPeriodo(
      int idMoneda, String fechaInicio, String fechaFin) async {
    final url = Uri.parse("$urlBase/listarporperiodo");
    try {
      final encabezado = await _getEncabezado();
      final respuesta = await http
          .post(
            url,
            headers: encabezado,
              body: jsonEncode({
                "idMoneda": idMoneda,
                "desde": fechaInicio,
                "hasta": fechaFin,
              }),
          )
          .timeout(const Duration(seconds: 10));
      if (respuesta.statusCode == 200) {
        return CambioMoneda.desdeListaJson(jsonDecode(respuesta.body));
      }
      if (respuesta.statusCode == 401) {
        throw Exception('Sesión inválida. Inicie sesión nuevamente.');
      }
      throw Exception('Error consultando cambios: ${respuesta.statusCode}');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
