import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Web / Chrome
      return 'http://localhost:5000';
    } else {
      // Android Emulator
      return 'http://10.0.2.2:5000';
    }
  }
}
