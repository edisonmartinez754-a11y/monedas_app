class Moneda {
  final int id;
  final String moneda;
  final String sigla;
  final String simbolo;
  final String emisor;

  Moneda({
    required this.id,
    required this.moneda,
    required this.sigla,
    required this.simbolo,
    required this.emisor,
  });

  factory Moneda.fromJson(Map<String, dynamic> json) {
    return Moneda(
      id: json['id'] ?? 0,
      moneda: json['nombre'] ?? json['moneda'] ?? '',
      sigla: json['sigla'] ?? '',
      simbolo: json['simbolo'] ?? '',
      emisor: json['emisor'] ?? '',
    );
  }

  static List<Moneda> fromJsonList(dynamic jsonList) {
    if (jsonList == null) return [];
    return (jsonList as List)
        .map((item) => Moneda.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Moneda && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CambioMoneda {
  final int id;
  final String fecha;
  final double valor;

  CambioMoneda({required this.id, required this.fecha, required this.valor});

  factory CambioMoneda.fromJson(Map<String, dynamic> json) {
    return CambioMoneda(
      id: json['id'] ?? 0,
      fecha: json['fecha']?.toString() ?? '',
      valor: (json['valor'] ?? 0).toDouble(),
    );
  }

  static List<CambioMoneda> fromJsonList(dynamic jsonList) {
    if (jsonList == null) return [];
    return (jsonList as List)
        .map((item) => CambioMoneda.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
