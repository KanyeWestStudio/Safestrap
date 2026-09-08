// lib/screens/font_changer_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/font_preset.dart';
import '../services/font_changer_service.dart';

class FontChangerTab extends StatefulWidget {
  const FontChangerTab({super.key});

  @override
  State<FontChangerTab> createState() => _FontChangerTabState();
}

class _FontChangerTabState extends State<FontChangerTab> {
  List<FontPreset> _presets = [];
  FontPreset? _selectedFont;
  bool _isApplying = false;
  bool _isMobile = false;

  @override
  void initState() {
    super.initState();
    _presets = FontChangerService.getPresetFonts();
    _loadCurrentFont();
    _isMobile = Theme.of(context).platform == TargetPlatform.android ||
                Theme.of(context).platform == TargetPlatform.iOS;
  }

  Future<void> _loadCurrentFont() async {
    final current = await FontChangerService.getCurrentFont();
    setState(() => _selectedFont = current);
  }

  Future<void> _selectPreset(FontPreset preset) async {
    setState(() => _selectedFont = preset);
    // Optionally preview automatically
  }

  Future<void> _pickCustomFont() async {
    try {
      final custom = await FontChangerService.pickCustomFont();
      if (custom != null) {
        setState(() => _selectedFont = custom);
        // Preview will be shown as we have the file path
      }
    } catch (e) {
      _showSnackBar('Error picking font: $e');
    }
  }

  Future<void> _applyFont() async {
    if (_selectedFont == null) {
      _showSnackBar('Please select a font first');
      return;
    }

    if (_isMobile) {
      _showSnackBar('Font changing is only supported on Windows/macOS');
      return;
    }

    setState(() => _isApplying = true);
    try {
      await FontChangerService.applyFont(_selectedFont!);
      _showSnackBar('Font applied successfully!');
    } catch (e) {
      _showSnackBar('Error applying font: $e');
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  Future<void> _resetFont() async {
    if (_isMobile) {
      _showSnackBar('Reset only works on desktop');
      return;
    }
    setState(() => _isApplying = true);
    try {
      await FontChangerService.resetToDefault();
      setState(() => _selectedFont = null);
      _showSnackBar('Reset to default Roblox font');
    } catch (e) {
      _showSnackBar('Error resetting: $e');
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ──────────────────────────────────────────
          Text(
            'Select a Font',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a font to replace Roblox\'s default (only works on Windows/macOS)',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // ─── Preset Grid ─────────────────────────────────────
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _presets.length + 1, // +1 for "Custom" card
              itemBuilder: (context, index) {
                if (index == _presets.length) {
                  // Custom font picker card
                  return _buildCustomCard();
                }
                final preset = _presets[index];
                return _buildPresetCard(preset);
              },
            ),
          ),

          // ─── Preview & Apply Area ───────────────────────────
          if (_selectedFont != null) ...[
            const Divider(color: Colors.white24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview:',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      _buildPreviewText(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isApplying ? null : _applyFont,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isApplying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Apply'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _isApplying ? null : _resetFont,
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPresetCard(FontPreset preset) {
    final isSelected = _selectedFont?.id == preset.id;
    return Card(
      color: isSelected ? Colors.blue.withValues(alpha: 0.3) : Colors.white10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: Colors.blue, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _selectPreset(preset),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Font preview in small text
            Expanded(
              child: FutureBuilder<FontLoader>(
                future: FontChangerService.loadFontForPreview(preset),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'Aa',
                      style: TextStyle(
                        fontFamily: preset.id,
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                preset.displayName,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCard() {
    final isSelected = _selectedFont?.isCustom == true;
    return Card(
      color: isSelected ? Colors.blue.withValues(alpha: 0.3) : Colors.white10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: Colors.blue, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: _pickCustomFont,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white54, size: 40),
            const SizedBox(height: 4),
            Text(
              'Pick Custom\nTTF/OTF',
              style: TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewText() {
    if (_selectedFont == null) return const SizedBox.shrink();

    return FutureBuilder<FontLoader>(
      future: FontChangerService.loadFontForPreview(_selectedFont!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            'The quick brown fox jumps over the lazy dog',
            style: TextStyle(
              fontFamily: _selectedFont!.id,
              fontSize: 20,
              color: Colors.white,
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Preview unavailable',
            style: TextStyle(color: Colors.redAccent, fontSize: 14),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
