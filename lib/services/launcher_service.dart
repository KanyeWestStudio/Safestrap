import 'dart:io';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/launch_profile.dart';

class LauncherService {
  static Future<bool> launchRoblox(LaunchProfile profile) async {
    if (Platform.isAndroid || Platform.isIOS) {
      return _launchMobile(profile);
    }
    return _launchDesktop(profile);
  }

  /// `roblox-player:1+launchmode:play+placeId:<id>+linkCode:<code>`, the
  /// protocol handler the desktop client registers.
  static String desktopDeepLink(LaunchProfile profile) {
    final buffer = StringBuffer('roblox-player:1');
    final placeId = profile.placeId;
    if (placeId != null) {
      buffer.write('+launchmode:play+placeId:$placeId');
      final code = profile.privateServerCode;
      if (code != null) {
        buffer.write('+linkCode:${Uri.encodeComponent(code)}');
      }
    }
    return buffer.toString();
  }

  /// `roblox://placeId=<id>&linkCode=<code>`, the scheme the mobile client
  /// registers.
  static String mobileDeepLink(LaunchProfile profile) {
    final placeId = profile.placeId;
    if (placeId == null) return 'roblox://';
    final buffer = StringBuffer('roblox://placeId=$placeId');
    final code = profile.privateServerCode;
    if (code != null) {
      buffer.write('&linkCode=${Uri.encodeComponent(code)}');
    }
    return buffer.toString();
  }

  static Future<bool> _launchDesktop(LaunchProfile profile) async {
    final target = desktopDeepLink(profile);
    try {
      if (Platform.isWindows) {
        // Hands the URI to the registered protocol handler without a shell,
        // so `&` and friends in a profile can never be interpreted.
        return await _exec('rundll32', ['url.dll,FileProtocolHandler', target]);
      }
      if (Platform.isMacOS) {
        return await _exec('open', [target]);
      }
      if (Platform.isLinux) {
        return await _exec('sober', [target]);
      }
      return false;
    } on ProcessException {
      return false;
    }
  }

  static Future<bool> _exec(String executable, List<String> arguments) async {
    final result = await Process.run(executable, arguments);
    return result.exitCode == 0;
  }

  static Future<bool> _launchMobile(LaunchProfile profile) async {
    for (final uri in [
      Uri.parse(mobileDeepLink(profile)),
      Uri.parse('robloxmobile://'),
    ]) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          return true;
        }
      } on PlatformException {
        continue;
      }
    }
    return false;
  }

  /// Where to send the user when no client could be launched.
  static String installPageUrl() {
    if (Platform.isAndroid) return 'market://details?id=com.roblox.client';
    if (Platform.isIOS) return 'https://apps.apple.com/app/roblox/id431946152';
    if (Platform.isLinux) return 'https://sober.vinegarhq.org/';
    return 'https://www.roblox.com/download';
  }

  /// Opens the install page for Roblox, used when no client is installed.
  static Future<bool> openStorePage() async {
    try {
      return await launchUrl(
        Uri.parse(installPageUrl()),
        mode: LaunchMode.externalApplication,
      );
    } on PlatformException {
      return false;
    }
  }
}
