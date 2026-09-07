// lib/screens/lag_tab.dart
import 'package:flutter/material.dart';
import 'package:safestrap/services/script_generator.dart';

class LagTab extends StatelessWidget {
  const LagTab({super.key});

  // Applies the selected preset using ScriptGenerator
  void _applyPreset(BuildContext context, Map<String, dynamic> flags) async {
    // Show a snackbar immediately to indicate action
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Applying preset...')),
    );

    try {
      // Generate, save, and apply the flags
      await ScriptGenerator.generateAndApply(flags);

      // Only show success if the widget is still mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preset applied successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying preset: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _presetButton(
            context,
            label: 'Max FPS (Potato)',
            color: Colors.redAccent,
            flags: {
              'DFFlagTextureQualityOverrideEnabled': true,
              'DFIntTextureQualityOverride': 1,
              'DFIntCSGLevelOfDetailSwitchingDistance': 100,
              'DFIntCSGLevelOfDetailSwitchingDistanceL12': 75,
              'DFIntCSGLevelOfDetailSwitchingDistanceL23': 100,
              'DFIntCSGLevelOfDetailSwitchingDistanceL34': 150,
              'FIntGrassMovementReducedMotionFactor': 0,
              'FIntDebugForceMSAASamples': 0,
              'FFlagHandleAltEnterFullscreenManually': true,
              'DFFlagDisableDPIScale': true,
              'FFlagDebugGraphicsPreferD3D11': true,
            },
          ),
          const SizedBox(height: 16),
          _presetButton(
            context,
            label: 'Balanced',
            color: Colors.orange,
            flags: {
              'DFFlagTextureQualityOverrideEnabled': true,
              'DFIntTextureQualityOverride': 2,
              'DFIntCSGLevelOfDetailSwitchingDistance': 200,
              'FIntGrassMovementReducedMotionFactor': 50,
              'FIntDebugForceMSAASamples': 2,
              'FFlagDebugGraphicsPreferD3D11': false,
            },
          ),
          const SizedBox(height: 16),
          _presetButton(
            context,
            label: 'High Quality',
            color: Colors.green,
            flags: {
              'DFFlagTextureQualityOverrideEnabled': false,
              'DFIntTextureQualityOverride': 3,
              'DFIntCSGLevelOfDetailSwitchingDistance': 500,
              'FIntGrassMovementReducedMotionFactor': 100,
              'FIntDebugForceMSAASamples': 4,
              'FFlagDebugGraphicsPreferVulkan': true,
              'FFlagHandleAltEnterFullscreenManually': true,
            },
          ),
          const Spacer(),
          const Text(
            'These presets adjust graphics & performance instantly.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _presetButton(
    BuildContext context, {
    required String label,
    required Color color,
    required Map<String, dynamic> flags,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: color, width: 1),
        ),
        onPressed: () => _applyPreset(context, flags),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
