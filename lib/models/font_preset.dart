class FontPreset {
  final String id;
  final String displayName;
  final String? assetPath;
  final String? filePath;

  const FontPreset({
    required this.id,
    required this.displayName,
    this.assetPath,
    this.filePath,
  });

  bool get isPreset => assetPath != null;
  bool get isCustom => filePath != null;
}
