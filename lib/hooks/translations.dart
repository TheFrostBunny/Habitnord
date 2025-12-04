import 'dart:convert';
import 'package:flutter/services.dart';

class Translations {
  static Map<String, dynamic>? _data;

  static Future<void> load(String locale) async {
    final jsonStr = await rootBundle.loadString('assets/i18n/$locale.json');
    _data = jsonDecode(jsonStr);
  }

  static String text(String key) {
    return _data?[key] ?? key;
  }
}
