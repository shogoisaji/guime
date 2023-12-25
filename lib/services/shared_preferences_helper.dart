import 'dart:convert';

import 'package:guime/models/pin_model.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // Future<Map<String, dynamic>?> loadPin(PinType pinType) async {
  //   if (_prefs == null) {
  //     await init();
  //   }
  //   String? jsonString = _prefs!.getString(pinType.toString().split('.')[1]);
  //   Map<String, dynamic>? data = jsonString != null ? jsonDecode(jsonString) : null;
  //   return data;
  // }
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
}
