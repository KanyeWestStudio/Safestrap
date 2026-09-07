import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScriptGenerator {
  static const String _scriptKey = 'lua_script';

  static String generateScript(Map<String, dynamic> flags) {
    final buffer = StringBuffer();
    buffer.writeln('profile{ name = "Custom", place_id = 1818, overlay = true }');
    buffer.writeln('fflags{');
    flags.forEach((key, value) {
      String formattedValue;
      if (value is bool) {
        formattedValue = value ? 'true' : 'false';
      } else if (value is String) {
        formattedValue = '"${value.replaceAll('"', '\\"')}"';
      } else {
        formattedValue = value.toString();
      }
      buffer.writeln('  $key = $formattedValue,');
    });
    buffer.writeln('}');
    return buffer.toString();
  }

  static Future<void> saveScriptToPrefs(String script) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scriptKey, script);
  }

  static Future<String?> loadScriptFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_scriptKey);
  }

  static Future<void> applyScript(String script) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/ClientAppSettings.json');
      await file.writeAsString(script);
      // Use debugPrint instead of print if needed
      // debugPrint('Script written to ${file.path}');
    } catch (e) {
      // debugPrint('Failed to write script: $e');
      rethrow;
    }
  }

  static Future<void> generateAndApply(Map<String, dynamic> flags) async {
    final script = generateScript(flags);
    await saveScriptToPrefs(script);
    await applyScript(script);
  }
}
