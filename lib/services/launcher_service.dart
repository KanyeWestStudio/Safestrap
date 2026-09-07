import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:url_launcher/url_launcher.dart';

class LauncherService {
  static Future<bool> launchRoblox() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return _launchMobile();
    }


    try {
      final shell = Shell();

      if (Platform.isWindows) {
        await shell.run('start roblox-player:1');
        return true;
      }
      if (Platform.isMacOS) {
        await shell.run('open -a Roblox');
        return true;
      }
      if (Platform.isLinux) {
        await shell.run('roblox-player || true');
        return true;
      }
      return false;
    } catch (e) {
      print('Launch failed: $e');
      return false;
    }
  }

  static Future<bool> _launchMobile() async {
    // Deep links that open the installed Roblox app.
    const schemes = ['roblox://', 'robloxmobile://'];

    for (final scheme in schemes) {
      try {
        final ok = await launchUrl(
          Uri.parse(scheme),
          mode: LaunchMode.externalApplication,
        );
        if (ok) return true;
      } catch (_) {

      }
    }


    final storeUri = Uri.parse(
      Platform.isAndroid
          ? 'market://details?id=com.roblox.client'
          : 'https://apps.apple.com/app/roblox/id431946152',
    );

    try {
      return await launchUrl(storeUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
