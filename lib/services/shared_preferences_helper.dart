import 'dart:convert';

import 'package:guime/models/pin_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    if (_prefs != null) {
      return;
    }
    _prefs = await SharedPreferences.getInstance();
  }

  Future<String> savePin(Pin pin) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs!.setString(pin.type.toString().split('.')[1], jsonEncode(pin.toJson()));
    return pin.type.toString().split('.')[1];
  }

  Future<Pin?> loadPin(PinType pinType) async {
    if (_prefs == null) {
      await init();
    }
    String? jsonString = _prefs!.getString(pinType.toString().split('.')[1]);
    Map<String, dynamic>? data = jsonString != null ? jsonDecode(jsonString) : null;
    if (data == null) {
      return null;
    }
    return Pin.fromJson(data);
  }

  Future<Map<String, Pin?>> loadAllPin() async {
    final Map<String, Pin?> pins = {};
    if (_prefs == null) {
      await init();
    }
    for (final pinType in PinType.values) {
      String? jsonString = _prefs!.getString(pinType.toString().split('.')[1]);
      Map<String, dynamic>? data = jsonString != null ? jsonDecode(jsonString) : null;
      pins[pinType.toString().split('.')[1]] = data != null ? Pin.fromJson(data) : null;
    }
    return pins;
  }

  Future<String?> loadSavedLanguage() async {
    return _prefs!.getString('language');
  }

  Future<void> saveLanguage(String language) async {
    _prefs!.setString('language', language);
  }
}
