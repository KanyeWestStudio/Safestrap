import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/font_preset.dart';

class FontChangerService {
  static const String _fontKey = 'selected_font';

  /// Built-in font presets.
  static List<FontPreset> getPresetFonts() {
    return const [
      FontPreset(
        id: 'lemon_milk',
        displayName: 'Lemon Milk',
        assetPath: 'assets/fonts/LemonMilk.otf',
      ),
      FontPreset(
        id: 'minecraft',
        displayName: 'Minecraft',
        assetPath: 'assets/fonts/Minecraft.ttf',
      ),
      FontPreset(
        id: 'starborn',
        displayName: 'Starborn',
        assetPath: 'assets/fonts/Starborn.ttf',
      ),
      FontPreset(
        id: 'matcha_mint',
        displayName: 'Matcha Mint',
        assetPath: 'assets/fonts/MatchaMint.ttf',
      ),
      FontPreset(
        id: 'milky_cream',
        displayName: 'Milky Cream',
        assetPath: 'assets/fonts/MilkyCream.ttf',
      ),
      FontPreset(
        id: 'ethnocent',
        displayName: 'Ethnocent',
        assetPath: 'assets/fonts/ETHNOCENT.ttf',
      ),
      FontPreset(
        id: 'bounce_dash',
        displayName: 'Bounce Dash',
        assetPath: 'assets/fonts/BounceDash.ttf',
      ),
      FontPreset(
        id: 'creamy_chicken',
        displayName: 'Creamy Chicken',
        assetPath: 'assets/fonts/CreamyChicken.ttf',
      ),
      FontPreset(
        id: 'super_mario',
        displayName: 'Super Mario',
        assetPath: 'assets/fonts/SuperMario.ttf',
      ),
    ];
  }

  /// Returns the currently selected font.
  static Future<FontPreset?> getCurrentFont() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_fontKey);

    if (id == null || id.isEmpty) {
      return null;
    }

    // Check built-in presets first.
    for (final preset in getPresetFonts()) {
      if (preset.id == id) {
        return preset;
      }
    }

    // Check whether the selected font is a custom font.
    final customFonts = await getCustomFonts();

    for (final font in customFonts) {
      if (font.id == id) {
        return font;
      }
    }

    return null;
  }

  /// Saves the selected font.
  static Future<void> setCurrentFont(FontPreset font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontKey, font.id);
  }

  /// Opens a file picker and imports a custom font.
  static Future<FontPreset?> importCustomFont() async {
    try {
      if (Platform.isAndroid) {
        await Permission.storage.request();
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf'],
        withData: false,
      );

      if (result == null || result.files.single.path == null) {
        return null;
      }

      final sourcePath = result.files.single.path!;
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        return null;
      }

      final directory = await _getCustomFontsDirectory();

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName = result.files.single.name;
      final destination = File('${directory.path}/$fileName');

      await sourceFile.copy(destination.path);

      final id = 'custom_${fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')}';

      return FontPreset(
        id: id,
        displayName: fileName,
        filePath: destination.path,
      );
    } catch (_) {
      return null;
    }
  }

  /// Gets all imported custom fonts.
  static Future<List<FontPreset>> getCustomFonts() async {
    try {
      final directory = await _getCustomFontsDirectory();

      if (!await directory.exists()) {
        return [];
      }

      final files = await directory.list().toList();

      return files
          .whereType<File>()
          .where((file) {
            final extension = file.path.split('.').last.toLowerCase();
            return extension == 'ttf' || extension == 'otf';
          })
          .map((file) {
            final fileName = file.path.split(Platform.pathSeparator).last;

            return FontPreset(
              id: 'custom_${fileName.replaceAll(
                RegExp(r'[^a-zA-Z0-9_]'),
                '_',
              )}',
              displayName: fileName,
              filePath: file.path,
            );
          })
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Deletes a custom font.
  static Future<bool> deleteCustomFont(FontPreset font) async {
    try {
      if (!font.isCustom || font.filePath == null) {
        return false;
      }

      final file = File(font.filePath!);

      if (await file.exists()) {
        await file.delete();
      }

      final current = await getCurrentFont();

      if (current?.id == font.id) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_fontKey);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Loads font bytes from a built-in asset.
  static Future<ByteData> getFontBytes(FontPreset font) async {
    if (font.assetPath == null) {
      throw Exception('This font does not have an asset path.');
    }

    return rootBundle.load(font.assetPath!);
  }

  /// Gets the directory where custom fonts are stored.
  static Future<Directory> _getCustomFontsDirectory() async {
    final appDirectory = await getApplicationSupportDirectory();
    return Directory('${appDirectory.path}/fonts');
  }

  /// Returns the Roblox fonts directory on supported desktop platforms.
  static Future<Directory?> getRobloxFontsDirectory() async {
    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];

      if (localAppData == null) {
        return null;
      }

      return Directory(
        '$localAppData/Roblox/Versions',
      );
    }

    if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];

      if (home == null) {
        return null;
      }

      return Directory(
        '$home/Library/Application Support/Roblox',
      );
    }

    return null;
  }
}
