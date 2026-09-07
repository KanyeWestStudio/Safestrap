import 'dart:convert';

/// Launch configuration produced by a config script.
class LaunchProfile {
  const LaunchProfile({
    this.name = 'default',
    this.fastFlags = const {},
    this.placeId,
    this.privateServerCode,
    this.overlay = true,
    this.logs = const [],
  });

  final String name;

  /// FastFlag name -> value (bool, int, double or String).
  final Map<String, Object> fastFlags;

  final int? placeId;
  final String? privateServerCode;
  final bool overlay;

  /// Messages emitted by the script through `log(...)`.
  final List<String> logs;

  String get fastFlagsJson =>
      const JsonEncoder.withIndent('  ').convert(fastFlags);

  Map<String, Object?> toJson() => {
        'name': name,
        'fastFlags': fastFlags,
        'placeId': placeId,
        'privateServerCode': privateServerCode,
        'overlay': overlay,
      };

  static LaunchProfile fromJson(Map<String, Object?> json) => LaunchProfile(
        name: json['name'] as String? ?? 'default',
        fastFlags: Map<String, Object>.from(
          json['fastFlags'] as Map? ?? const {},
        ),
        placeId: json['placeId'] as int?,
        privateServerCode: json['privateServerCode'] as String?,
        overlay: json['overlay'] as bool? ?? true,
      );
}
