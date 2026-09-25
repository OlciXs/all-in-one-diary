import 'package:flutter/foundation.dart';

//przez wifi http://192.168.0.28:3000
class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    // Dla emulatora Androida
    return 'http://10.0.2.2:3000';
  }
}
