import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/launch_profile.dart';
import 'script_engine.dart';

class ConfigService {
  static const _scriptKey = 'config_script';
  static const _profileKey = 'launch_profile';

  static Future<String> loadScript() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_scriptKey) ?? ScriptEngine.defaultScript;
  }

  static Future<void> saveScript(String source) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scriptKey, source);
  }

  static Future<void> saveProfile(LaunchProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  static Future<LaunchProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return const LaunchProfile();
    try {
      return LaunchProfile.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );
    } on FormatException {
      return const LaunchProfile();
    }
  }
}
