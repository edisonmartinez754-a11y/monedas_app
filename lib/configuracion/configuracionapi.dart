import 'package:flutter/foundation.dart';

class ConfiguracionApi {
  static String get urlBase {
    if (kIsWeb) {
      return 'http://127.0.0.1:8080/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://127.0.0.1:8080/api';
  }
}
