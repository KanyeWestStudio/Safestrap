import 'dart:io';
import 'package:process_run/shell.dart';

/// Safe launcher
class LauncherService {
  static Future<bool> launchRoblox() async {
    try {
      final shell = Shell();

      if (Platform.isWindows) {
        // Try the official protocol first
        await shell.run('start roblox-player:1');
        return true;
      }

      if (Platform.isMacOS) {
        await shell.run('open -a Roblox');
        return true;
      }

      if (Platform.isLinux) {
        // Basic Linux support (can be improved later)
        await shell.run('roblox-player || true');
        return true;
      }

      // Mobile – open the Roblox app or store
      return false;
    } catch (e) {
      print('Launch failed: $e');
      return false;
    }
  }
}
