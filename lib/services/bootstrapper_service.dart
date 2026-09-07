import 'dart:io';

import 'package:flutter_floatwing/flutter_floatwing.dart';

import 'launcher_service.dart';

class BootstrapperService {
  static Future<String> start() async {

    if (!Platform.isAndroid && !Platform.isIOS) {
      final ok = await LauncherService.launchRoblox();
      return ok ? 'Roblox launched!' : 'Could not launch Roblox';
    }

    final plugin = FloatwingPlugin();

    try {
      // 1. Overlay permission (draw over other apps)
      final granted = await plugin.checkPermission();
      if (!granted) {
        await plugin.openPermissionSetting();
        return 'Grant overlay permission, then press Launch again';
      }

      // 2. Launch Roblox
      final launched = await LauncherService.launchRoblox();
      if (!launched) {
        return 'Could not launch Roblox';
      }

      // 3. Show the corner menu
      await plugin.initialize();
      await WindowConfig(
        entry: 'overlayMain',
        draggable: true,
        gravity: GravityType.RightBottom,
        autosize: true,
      ).to().create(start: true);

      return 'Roblox launched!';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
