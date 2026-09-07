import 'dart:io';

import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/launch_profile.dart';

class LauncherService {
  static Future<bool> launchRoblox(LaunchProfile profile) async {
    if (Platform.isAndroid || Platform.isIOS) {
      return _launchMobile(profile);
    }
    return _launchDesktop(profile);
  }

  /// `roblox-player:1+launchmode:play+placeId:<id>` style deep link, reduced to
  /// the parts a bootstrapper can supply without an auth ticket.
  static String _deepLink(LaunchProfile profile) {
    final buffer = StringBuffer('roblox://');
    if (profile.placeId != null) {
      buffer.write('placeId=${profile.placeId}');
      if (profile.privateServerCode != null) {
        buffer.write('&linkCode=${profile.privateServerCode}');
      }
    }
    return buffer.toString();
  }

  static Future<bool> _launchDesktop(LaunchProfile profile) async {
    final shell = Shell(throwOnError: true);
    final placeId = profile.placeId;

    try {
      if (Platform.isWindows) {
        final target = placeId == null
            ? 'roblox-player:1'
            : 'roblox-player:1+launchmode:play+placeId:$placeId';
        await shell.run('cmd /c start "" "$target"');
        return true;
      }
      if (Platform.isMacOS) {
        await shell.run('open -a Roblox');
        return true;
      }
      if (Platform.isLinux) {
        await shell.run('sober ${_deepLink(profile)}');
        return true;
      }
      return false;
    } on ShellException {
      return false;
    } on ProcessException {
      return false;
    }
  }

  static Future<bool> _launchMobile(LaunchProfile profile) async {
    for (final uri in [
      Uri.parse(_deepLink(profile)),
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

  /// Opens the store page for Roblox, used when no client is installed.
  static Future<bool> openStorePage() async {
    final storeUri = Uri.parse(
      Platform.isAndroid
          ? 'market://details?id=com.roblox.client'
          : 'https://apps.apple.com/app/roblox/id431946152',
    );
    try {
      return await launchUrl(storeUri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  }
}
