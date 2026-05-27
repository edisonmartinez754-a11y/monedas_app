import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../models/moneda_model.dart';

class MonedaService {
  final String baseUrl = "${ApiConfig.baseUrl}/monedas";

  Future<Map<String, String>> _getHeaders() async {
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

  Future<List<Moneda>> listAll() async {
    final url = Uri.parse("$baseUrl/listar");
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return Moneda.fromJsonList(jsonDecode(decodedBody));
      }
      if (response.statusCode == 401) {
        throw Exception('Sesión inválida. Inicie sesión nuevamente.');
      }
      throw Exception('Error cargando monedas: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CambioMoneda>> listByPeriod(
      int currencyId, String startDate, String endDate) async {
    final url = Uri.parse("$baseUrl/listarporperiodo");
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            url,
            headers: headers,
              body: jsonEncode({
                "idMoneda": currencyId,
                "desde": startDate,
                "hasta": endDate,
              }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return CambioMoneda.fromJsonList(jsonDecode(decodedBody));
      }
      if (response.statusCode == 401) {
        throw Exception('Sesión inválida. Inicie sesión nuevamente.');
      }
      throw Exception('Error consultando cambios: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
