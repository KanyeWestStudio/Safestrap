import 'dart:io';

import '../models/launch_profile.dart';

enum FastFlagResult { applied, cleared, unsupported, failed }

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
    final directories = _clientSettingsDirectories();
    if (directories.isEmpty) {
      return const FastFlagOutcome(
        FastFlagResult.unsupported,
        'FastFlags need a desktop Roblox install',
      );
    }

    // An empty profile has to overwrite the settings file, otherwise the flags
    // from the previous launch stay active.
    final clearing = profile.fastFlags.isEmpty;
    var written = 0;
    var failed = 0;
    Object? lastError;
    for (final directory in directories) {
      final file = File('${directory.path}${Platform.pathSeparator}'
          'ClientAppSettings.json');
      try {
        if (clearing) {
          if (!await file.exists()) continue;
          await file.writeAsString('{}');
        } else {
          await directory.create(recursive: true);
          await file.writeAsString(profile.fastFlagsJson);
        }
        written++;
      } catch (e) {
        failed++;
        lastError = e;
      }
    }

    // A partial update still leaves stale flags in the installs that were not
    // written, so any failure is reported instead of the successes hiding it.
    if (failed > 0) {
      return FastFlagOutcome(
        FastFlagResult.failed,
        written == 0
            ? 'could not write ClientAppSettings.json: $lastError'
            : '$failed of ${written + failed} Roblox installs kept their old '
                'FastFlags: $lastError',
      );
    }
    if (clearing) {
      return FastFlagOutcome(
        FastFlagResult.cleared,
        written == 0 ? 'no FastFlags set' : 'FastFlags cleared',
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
