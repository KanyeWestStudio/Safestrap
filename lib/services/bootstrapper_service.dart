import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_floatwing/flutter_floatwing.dart';

import '../models/launch_profile.dart';
import 'config_service.dart';
import 'fastflag_service.dart';
import 'launcher_service.dart';
import 'script_engine.dart';

class BootstrapperService {
  /// The overlay plugin is Android only.
  static bool get supportsOverlay => Platform.isAndroid;

  static Future<String> start() async {
    final LaunchProfile profile;
    try {
      profile = await ScriptEngine.runGuarded(await ConfigService.loadScript());
    } on ScriptException catch (e) {
      return 'Config script failed: $e';
    }
    await ConfigService.saveProfile(profile);

    final flags = await FastFlagService.apply(profile);
    final flagNote = switch (flags.result) {
      FastFlagResult.applied || FastFlagResult.failed => ' (${flags.detail})',
      _ => '',
    };

    final wantsOverlay = profile.overlay && supportsOverlay;
    if (wantsOverlay) {
      final bool granted;
      try {
        granted = await _ensureOverlayPermission();
      } on PlatformException catch (e) {
        return 'Overlay permission unavailable: ${e.message}';
      }
      if (!granted) {
        return 'Grant overlay permission, then press Launch again';
      }
    }

    if (!await LauncherService.launchRoblox(profile)) {
      await LauncherService.openStorePage();
      return 'Could not launch Roblox — is it installed?';
    }

    if (wantsOverlay) {
      try {
        await _showOverlay();
      } on PlatformException catch (e) {
        return 'Roblox launched$flagNote, overlay failed: ${e.message}';
      }
    }

    return 'Roblox launched$flagNote';
  }

  static Future<bool> _ensureOverlayPermission() async {
    final plugin = FloatwingPlugin();
    if (await plugin.checkPermission()) return true;
    await plugin.openPermissionSetting();
    return false;
  }

  static Future<void> _showOverlay() async {
    final plugin = FloatwingPlugin();
    await plugin.initialize();
    await WindowConfig(
      entry: 'overlayMain',
      draggable: true,
      gravity: GravityType.RightBottom,
      autosize: true,
    ).to().create(start: true);
  }
}
