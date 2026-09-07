import 'package:flutter/material.dart';

class LagTab extends StatelessWidget {
  const LagTab({super.key});

  void _applyPreset(BuildContext context, String presetName) {
    Map<String, dynamic> flags;
    switch (presetName) {
      case 'Max FPS (Potato)':
        flags = {
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
        };
        break;
      case 'Balanced':
        flags = {
          'DFFlagTextureQualityOverrideEnabled': true,
          'DFIntTextureQualityOverride': 2,
          'DFIntCSGLevelOfDetailSwitchingDistance': 200,
          'FIntGrassMovementReducedMotionFactor': 50,
          'FIntDebugForceMSAASamples': 2,
          'FFlagDebugGraphicsPreferD3D11': false,
        };
        break;
      case 'High Quality':
        flags = {
          'DFFlagTextureQualityOverrideEnabled': false,
          'DFIntTextureQualityOverride': 3,
          'DFIntCSGLevelOfDetailSwitchingDistance': 500,
          'FIntGrassMovementReducedMotionFactor': 100,
          'FIntDebugForceMSAASamples': 4,
          'FFlagDebugGraphicsPreferVulkan': true,
          'FFlagHandleAltEnterFullscreenManually': true,
        };
        break;
      default:
        return;
    }
    // Save and apply – you'll call your script generator here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$presetName applied!')),
    );
    print('Applied preset: $presetName with flags: $flags');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _presetButton('Max FPS (Potato)', Colors.redAccent),
          const SizedBox(height: 16),
          _presetButton('Balanced', Colors.orange),
          const SizedBox(height: 16),
          _presetButton('High Quality', Colors.green),
          const Spacer(),
          Text(
            'These presets adjust graphics & performance instantly.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _presetButton(String label, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: color, width: 1),
        ),
        onPressed: () => _applyPreset(context, label),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
