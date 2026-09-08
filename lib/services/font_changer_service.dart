// lib/services/font_changer_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../models/font_preset.dart';

class FontChangerService {
  static const String _prefKey = 'selected_font_id';
  static const String _prefCustomPath = 'custom_font_path';

  // ─── List of preset fonts ──────────────────────────────────
  static List<FontPreset> getPresetFonts() {
    return const [
      FontPreset(id: 'lemon_milk', displayName: 'Lemon Milk', assetPath: 'assets/fonts/LemonMilk.otf'),
      FontPreset(id: 'minecraft', displayName: 'Minecraft', assetPath: 'assets/fonts/Minecraft.ttf'),
      FontPreset(id: 'starborn', displayName: 'Starborn', assetPath: 'assets/fonts/Starborn.ttf'),
      FontPreset(id: 'matcha_mint', displayName: 'Matcha Mint', assetPath: 'assets/fonts/MatchaMint.ttf'),
      FontPreset(id: 'milky_cream', displayName: 'Milky Cream', assetPath: 'assets/fonts/MilkyCream.ttf'),
      FontPreset(id: 'ethnocent', displayName: 'ETHNOCENT', assetPath: 'assets/fonts/ETHNOCENT.ttf'),
      FontPreset(id: 'bounce_dash', displayName: 'Bounce Dash', assetPath: 'assets/fonts/BounceDash.ttf'),
      FontPreset(id: 'creamy_chicken', displayName: 'Creamy Chicken', assetPath: 'assets/fonts/CreamyChicken.ttf'),
      FontPreset(id: 'super_mario', displayName: 'Super Mario', assetPath: 'assets/fonts/SuperMario.ttf'),
    ];
  }

  // ─── Get currently selected font ──────────────────────────
  static Future<FontPreset?> getCurrentFont() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefKey);
    if (id == null) return null;

    // Check if it's a preset
    final preset = getPresetFonts().firstWhere((f) => f.id == id, orElse: () => throw Exception('Font not found'));
    if (preset.id == id) return preset;

    // Otherwise it's a custom font
    final customPath = prefs.getString(_prefCustomPath);
    if (customPath != null && await File(customPath).exists()) {
      return FontPreset(id: id, displayName: 'Custom', filePath: customPath);
    }
    return null;
  }

  // ─── Apply a font (preset or custom) ──────────────────────
  static Future<void> applyFont(FontPreset font) async {
    // 1. Save selection to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, font.id);
    if (font.isCustom && font.filePath != null) {
      await prefs.setString(_prefCustomPath, font.filePath!);
    } else {
      await prefs.remove(_prefCustomPath);
    }

    // 2. If it's a preset, copy from asset to a temporary file
    //    then copy to Roblox's font directory.
    //    For custom, we use the file directly.
    String sourcePath;
    if (font.isPreset && font.assetPath != null) {
      // Load font from asset as bytes and write to temp file
      final byteData = await rootBundle.load(font.assetPath!);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_font.ttf');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      sourcePath = tempFile.path;
    } else if (font.isCustom && font.filePath != null) {
      sourcePath = font.filePath!;
    } else {
      throw Exception('Invalid font source');
    }

    // 3. Determine Roblox fonts directory
    final robloxFontsDir = await _getRobloxFontsDirectory();
    if (robloxFontsDir == null) {
      throw Exception('Roblox not found or unsupported platform');
    }

    // 4. Backup original font if not already backed up
    final originalFont = File('${robloxFontsDir.path}/BuilderSans.ttf');
    final backupFont = File('${robloxFontsDir.path}/BuilderSans.ttf.backup');
    if (await originalFont.exists() && !await backupFont.exists()) {
      await originalFont.copy(backupFont.path);
    }

    // 5. Copy the new font and rename to BuilderSans.ttf
    await File(sourcePath).copy(originalFont.path);
  }

  // ─── Reset to Roblox's default font ──────────────────────
  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    await prefs.remove(_prefCustomPath);

    final robloxFontsDir = await _getRobloxFontsDirectory();
    if (robloxFontsDir == null) return;

    final originalFont = File('${robloxFontsDir.path}/BuilderSans.ttf');
    final backupFont = File('${robloxFontsDir.path}/BuilderSans.ttf.backup');
    if (await backupFont.exists()) {
      await backupFont.copy(originalFont.path);
      await backupFont.delete();
    }
  }

  // ─── Helper: find Roblox fonts directory ─────────────────
  static Future<Directory?> _getRobloxFontsDirectory() async {
    if (Platform.isWindows) {
      // Windows: %localappdata%\Roblox\Versions\version-*\content\fonts
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData == null) return null;
      final robloxDir = Directory('$localAppData\\Roblox\\Versions');
      if (!await robloxDir.exists()) return null;
      // Find the latest version folder (lexicographically)
      final versionDirs = await robloxDir.list().where((e) => e is Directory && e.path.contains('version-')).toList();
      if (versionDirs.isEmpty) return null;
      // Sort by path (usually version-* with increasing numbers)
      versionDirs.sort((a, b) => a.path.compareTo(b.path));
      final latestVersion = versionDirs.last as Directory;
      final fontsDir = Directory('${latestVersion.path}\\content\\fonts');
      if (await fontsDir.exists()) return fontsDir;
    } else if (Platform.isMacOS) {
      // macOS: ~/Library/Application Support/Roblox/Versions/version-*/content/fonts
      final home = Platform.environment['HOME'];
      if (home == null) return null;
      final robloxDir = Directory('$home/Library/Application Support/Roblox/Versions');
      if (!await robloxDir.exists()) return null;
      final versionDirs = await robloxDir.list().where((e) => e is Directory && e.path.contains('version-')).toList();
      if (versionDirs.isEmpty) return null;
      versionDirs.sort((a, b) => a.path.compareTo(b.path));
      final latestVersion = versionDirs.last as Directory;
      final fontsDir = Directory('${latestVersion.path}/content/fonts');
      if (await fontsDir.exists()) return fontsDir;
    } else {
      // Android/iOS: not supported (sandbox) – we'll return null
      // You could try to access Roblox's data directory with permissions,
      // but it's unlikely to work without root.
      return null;
    }
    return null;
  }

  // ─── Pick a custom TTF file ───────────────────────────────
  static Future<FontPreset?> pickCustomFont() async {
    // Request storage permission on Android
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ttf', 'otf'],
    );
    if (result == null) return null;
    final file = result.files.first;
    final path = file.path;
    if (path == null) return null;

    // Create a FontPreset for this custom font
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    return FontPreset(
      id: id,
      displayName: file.name,
      filePath: path,
    );
  }

  // ─── Dynamically load a font for preview ──────────────────
  static Future<FontLoader> loadFontForPreview(FontPreset font) async {
    final byteData = await _getFontBytes(font);
    final loader = FontLoader(font.id);
    loader.addFont(byteData);
    await loader.load();
    return loader;
  }

  static Future<ByteData> _getFontBytes(FontPreset font) async {
    if (font.isPreset && font.assetPath != null) {
      return await rootBundle.load(font.assetPath!);
    } else if (font.isCustom && font.filePath != null) {
      final file = File(font.filePath!);
      final bytes = await file.readAsBytes();
      return ByteData.view(bytes.buffer);
    } else {
      throw Exception('Font source not found');
    }
  }
}
