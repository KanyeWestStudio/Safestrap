import 'dart:io';

import '../models/launch_profile.dart';

enum FastFlagResult { applied, noFlags, unsupported, failed }

class FastFlagOutcome {
  const FastFlagOutcome(this.result, this.detail);

  final FastFlagResult result;
  final String detail;
}

/// Writes the FastFlags of a [LaunchProfile] into the Roblox client's
/// `ClientAppSettings.json`.
///
/// Only desktop clients expose a writable settings directory; on Android the
/// Roblox data directory is sandboxed, so flags are kept in the profile and
/// reported as unsupported instead of silently doing nothing.
class FastFlagService {
  static Future<FastFlagOutcome> apply(LaunchProfile profile) async {
    if (profile.fastFlags.isEmpty) {
      return const FastFlagOutcome(FastFlagResult.noFlags, 'no FastFlags set');
    }

    final directories = _clientSettingsDirectories();
    if (directories.isEmpty) {
      return const FastFlagOutcome(
        FastFlagResult.unsupported,
        'FastFlags need a desktop Roblox install',
      );
    }

    var written = 0;
    Object? lastError;
    for (final directory in directories) {
      try {
        await directory.create(recursive: true);
        final file = File('${directory.path}${Platform.pathSeparator}'
            'ClientAppSettings.json');
        await file.writeAsString(profile.fastFlagsJson);
        written++;
      } catch (e) {
        lastError = e;
      }
    }

    if (written == 0) {
      return FastFlagOutcome(
        FastFlagResult.failed,
        'could not write ClientAppSettings.json: $lastError',
      );
    }
    return FastFlagOutcome(
      FastFlagResult.applied,
      '${profile.fastFlags.length} FastFlags applied',
    );
  }

  static List<Directory> _clientSettingsDirectories() {
    final env = Platform.environment;

    if (Platform.isWindows) {
      final localAppData = env['LOCALAPPDATA'];
      if (localAppData == null) return const [];
      final versions = Directory('$localAppData\\Roblox\\Versions');
      if (!versions.existsSync()) return const [];
      return versions
          .listSync()
          .whereType<Directory>()
          .map((version) => Directory('${version.path}\\ClientSettings'))
          .toList();
    }

    if (Platform.isMacOS) {
      final app = Directory('/Applications/Roblox.app');
      if (!app.existsSync()) return const [];
      return [
        Directory('/Applications/Roblox.app/Contents/MacOS/ClientSettings'),
      ];
    }

    if (Platform.isLinux) {
      final home = env['HOME'];
      if (home == null) return const [];
      // Sober is the common Linux Roblox client and reads the same file.
      final sober = Directory('$home/.var/app/org.vinegarhq.Sober/data/sober');
      if (!sober.existsSync()) return const [];
      return [Directory('${sober.path}/exe/ClientSettings')];
    }

    return const [];
  }
}
