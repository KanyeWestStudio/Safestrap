// Inside FontChangerService
static Future<void> applyFont(String fontFilePath) async {
  // 1. Find the Roblox fonts directory
  final fontsDir = await _getRobloxFontsDirectory();
  // 2. Backup the original font
  await _backupOriginalFont(fontsDir);
  // 3. Copy the new font and rename it
  final newFontFile = File('${fontsDir.path}/BuilderSans.ttf');
  await File(fontFilePath).copy(newFontFile.path);
}

static Future<void> resetToDefault() async {
  // Delete the custom font and restore the backup
}
