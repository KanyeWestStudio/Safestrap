// lib/services/script_generator.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScriptGenerator {
  static const String _scriptKey = 'lua_script';

  /// Generate the Lua script from a map of FastFlags.
  static String generateScript(Map<String, dynamic> flags) {
    final buffer = StringBuffer();
    buffer.writeln('profile{ name = "Custom", place_id = 1818, overlay = true }');
    buffer.writeln('fflags{');
    flags.forEach((key, value) {
      // Escape strings and format booleans
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

  /// Save the generated script to shared_preferences (so it persists).
  static Future<void> saveScriptToPrefs(String script) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scriptKey, script);
  }

  /// Load the last saved script from prefs.
  static Future<String?> loadScriptFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_scriptKey);
  }

  /// Apply the script (write to ClientAppSettings.json or run the launcher).
  static Future<void> applyScript(String script) async {
    // Determine the correct path for ClientAppSettings.json.
    // On Android: usually in /data/data/com.roblox.client/files/
    // On Windows: %LOCALAPPDATA%/Roblox/Versions/.../ClientAppSettings.json
    // This is a simplified example – you may need to detect platform.
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/ClientAppSettings.json');
      // For now, just write the script to a file for debugging.
      // In reality, you might invoke your Roblox launcher with this script.
      await file.writeAsString(script);
      print('Script written to ${file.path}');
    } catch (e) {
      print('Failed to write script: $e');
      rethrow;
    }
  }

  /// Full flow: generate script from flags, save to prefs, and apply.
  static Future<void> generateAndApply(Map<String, dynamic> flags) async {
    final script = generateScript(flags);
    await saveScriptToPrefs(script);
    await applyScript(script);
  }
}
