// lib/screens/fflags_tab.dart
import 'package:flutter/material.dart';

class FFlagsTab extends StatefulWidget {
  const FFlagsTab({super.key});

  @override
  State<FFlagsTab> createState() => _FFlagsTabState();
}

class _FFlagsTabState extends State<FFlagsTab> {
  // ─── All flags with defaults ────────────────────────────────
  Map<String, dynamic> _flags = {
    // Performance
    'DFIntTaskSchedulerTargetFps': 60,
    'FFlagTaskSchedulerLimitTargetFpsTo2402': false,

    // Rendering
    'FFlagDebugGraphicsPreferVulkan': false,
    'FFlagDebugGraphicsPreferOpenGL': false,
    'FFlagDebugGraphicsPreferD3D11': true,
    'FFlagDebugGraphicsPreferD3D11FL10': false,
    'FFlagDebugGraphicsPreferMetal': false,
    'DFIntDebugFRMQualityLevelOverride': 2,
    'FIntDebugForceMSAASamples': 0,

    // Environment
    'DFIntCSGLevelOfDetailSwitchingDistance': 200,
    'DFIntCSGLevelOfDetailSwitchingDistanceL12': 100,
    'DFIntCSGLevelOfDetailSwitchingDistanceL23': 150,
    'DFIntCSGLevelOfDetailSwitchingDistanceL34': 250,
    'FIntGrassMovementReducedMotionFactor': 50,
    'FIntFRMMaxGrassDistance': 100,
    'FIntFRMMinGrassDistance': 0,

    // UI & QoL
    'FFlagHandleAltEnterFullscreenManually': true,
    'DFFlagDisableDPIScale': false,
    'FFlagDebugDisplayFPS': false,
    'FStringGetPlayerImageDefaultTimeout': '5',
    'FIntFullscreenTitleBarTriggerDelayMillis': 1000,

    // Debug & Stability
    'DFFlagDebugDisableTimeoutDisconnect': false,
    'FFlagDebugDisableTelemetryPoint': false,
    'FFlagDebugSkyGray': false,
    'DFFlagDebugPauseVoxelizer': false,
  };

  // ─── Category definitions ────────────────────────────────────
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Performance & Framerate',
      'icon': Icons.speed,
      'keys': [
        'DFIntTaskSchedulerTargetFps',
        'FFlagTaskSchedulerLimitTargetFpsTo2402',
      ],
    },
    {
      'title': 'Rendering & Graphics API',
      'icon': Icons.image,
      'keys': [
        'FFlagDebugGraphicsPreferVulkan',
        'FFlagDebugGraphicsPreferOpenGL',
        'FFlagDebugGraphicsPreferD3D11',
        'FFlagDebugGraphicsPreferD3D11FL10',
        'FFlagDebugGraphicsPreferMetal',
        'DFIntDebugFRMQualityLevelOverride',
        'FIntDebugForceMSAASamples',
      ],
    },
    {
      'title': 'Environment & Geometry',
      'icon': Icons.landscape,
      'keys': [
        'DFIntCSGLevelOfDetailSwitchingDistance',
        'DFIntCSGLevelOfDetailSwitchingDistanceL12',
        'DFIntCSGLevelOfDetailSwitchingDistanceL23',
        'DFIntCSGLevelOfDetailSwitchingDistanceL34',
        'FIntGrassMovementReducedMotionFactor',
        'FIntFRMMaxGrassDistance',
        'FIntFRMMinGrassDistance',
      ],
    },
    {
      'title': 'UI & Quality of Life',
      'icon': Icons.settings_applications,
      'keys': [
        'FFlagHandleAltEnterFullscreenManually',
        'DFFlagDisableDPIScale',
        'FFlagDebugDisplayFPS',
        'FStringGetPlayerImageDefaultTimeout',
        'FIntFullscreenTitleBarTriggerDelayMillis',
      ],
    },
    {
      'title': 'Debug & Stability',
      'icon': Icons.bug_report,
      'keys': [
        'DFFlagDebugDisableTimeoutDisconnect',
        'FFlagDebugDisableTelemetryPoint',
        'FFlagDebugSkyGray',
        'DFFlagDebugPauseVoxelizer',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          // ─── Save button at top ──────────────────────────────
          ElevatedButton.icon(
            onPressed: _saveAndApply,
            icon: const Icon(Icons.save),
            label: const Text('Save All FFlags'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          // ─── Each category as an ExpansionTile ──────────────
          ..._categories.map((cat) => _buildCategory(cat)),
        ],
      ),
    );
  }

  // ─── Build a single category expansion tile ──────────────────
  Widget _buildCategory(Map<String, dynamic> cat) {
    final keys = cat['keys'] as List<String>;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(cat['icon'], color: Colors.blueAccent),
        title: Text(
          cat['title'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        collapsedIconColor: Colors.white54,
        iconColor: Colors.white,
        children: keys.map((key) => _buildFlagTile(key)).toList(),
      ),
    );
  }

  // ─── Build a single flag control (switch, slider, or dropdown) ──
  Widget _buildFlagTile(String key) {
    final value = _flags[key];
    if (value is bool) {
      return _buildSwitchTile(key, value);
    } else if (key == 'DFIntTaskSchedulerTargetFps') {
      return _buildSliderTile(key, value ?? 60, 30, 300);
    } else if (key == 'DFIntDebugFRMQualityLevelOverride') {
      return _buildDropdownTile(key, value ?? 2, [0, 1, 2, 3]);
    } else if (key == 'FIntDebugForceMSAASamples') {
      return _buildDropdownTile(key, value ?? 0, [0, 2, 4, 8]);
    } else if (key == 'FStringGetPlayerImageDefaultTimeout') {
      return _buildTextInputTile(key, value ?? '5');
    } else if (value is int) {
      return _buildSliderTile(key, value, 0, 1000);
    } else {
      // fallback
      return ListTile(
        title: Text(key, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        subtitle: Text('${value ?? '?'}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
        dense: true,
      );
    }
  }

  // ─── Switch tile ──────────────────────────────────────────────
  Widget _buildSwitchTile(String key, bool val) {
    return SwitchListTile(
      title: Text(_displayName(key), style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(key, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      value: val,
      onChanged: (newVal) => setState(() => _flags[key] = newVal),
      dense: true,
      activeColor: Colors.blue,
    );
  }

  // ─── Slider tile (for ints) ──────────────────────────────────
  Widget _buildSliderTile(String key, int val, int min, int max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _displayName(key),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Text(
                val.toString(),
                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Slider(
          value: val.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: (max - min) ~/ 10 > 0 ? (max - min) ~/ 10 : null,
          onChanged: (newVal) => setState(() => _flags[key] = newVal.round()),
          activeColor: Colors.blue,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            key,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ),
        const Divider(color: Colors.white24, height: 8),
      ],
    );
  }

  // ─── Dropdown tile ────────────────────────────────────────────
  Widget _buildDropdownTile(String key, int val, List<int> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<int>(
        value: val,
        dropdownColor: Colors.grey[900],
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: _displayName(key),
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        ),
        items: options.map((v) {
          return DropdownMenuItem<int>(
            value: v,
            child: Text(v.toString(), style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: (newVal) => setState(() => _flags[key] = newVal!),
      ),
    );
  }

  // ─── Text input tile (for strings) ──────────────────────────
  Widget _buildTextInputTile(String key, String val) {
    final controller = TextEditingController(text: val);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: _displayName(key),
          labelStyle: const TextStyle(color: Colors.white70),
          hintText: key,
          hintStyle: const TextStyle(color: Colors.white38),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        ),
        onChanged: (newVal) => _flags[key] = newVal,
      ),
    );
  }

  // ─── Helper: human-readable name ─────────────────────────────
  String _displayName(String key) {
    const map = {
      'DFIntTaskSchedulerTargetFps': 'Target FPS',
      'FFlagTaskSchedulerLimitTargetFpsTo2402': 'Unlock 240+ FPS',
      'FFlagDebugGraphicsPreferVulkan': 'Prefer Vulkan',
      'FFlagDebugGraphicsPreferOpenGL': 'Prefer OpenGL',
      'FFlagDebugGraphicsPreferD3D11': 'Prefer DirectX 11',
      'FFlagDebugGraphicsPreferD3D11FL10': 'Prefer DirectX 10',
      'FFlagDebugGraphicsPreferMetal': 'Prefer Metal (macOS)',
      'DFIntDebugFRMQualityLevelOverride': 'Graphics Quality Level',
      'FIntDebugForceMSAASamples': 'MSAA Samples',
      'DFIntCSGLevelOfDetailSwitchingDistance': 'Master LOD Distance',
      'DFIntCSGLevelOfDetailSwitchingDistanceL12': 'LOD Transition 1→2',
      'DFIntCSGLevelOfDetailSwitchingDistanceL23': 'LOD Transition 2→3',
      'DFIntCSGLevelOfDetailSwitchingDistanceL34': 'LOD Transition 3→4',
      'FIntGrassMovementReducedMotionFactor': 'Grass Movement',
      'FIntFRMMaxGrassDistance': 'Max Grass Distance',
      'FIntFRMMinGrassDistance': 'Min Grass Distance',
      'FFlagHandleAltEnterFullscreenManually': 'Manual Fullscreen',
      'DFFlagDisableDPIScale': 'Disable DPI Scaling',
      'FFlagDebugDisplayFPS': 'Show FPS Counter',
      'FStringGetPlayerImageDefaultTimeout': 'Avatar Image Timeout (sec)',
      'FIntFullscreenTitleBarTriggerDelayMillis': 'Fullscreen Title Delay (ms)',
      'DFFlagDebugDisableTimeoutDisconnect': 'Disable Timeout Disconnect',
      'FFlagDebugDisableTelemetryPoint': 'Disable Telemetry',
      'FFlagDebugSkyGray': 'Gray Sky (Debug)',
      'DFFlagDebugPauseVoxelizer': 'Pause Voxelizer (Debug)',
    };
    return map[key] ?? key;
  }

  // ─── Save and apply ──────────────────────────────────────────
  void _saveAndApply() {
    // TODO: Save to shared_preferences and regenerate Lua script
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('FFlags saved! (Connect to your script generator)')),
    );
    print('Saved flags: $_flags');
    // You can call your script generator here:
    // ScriptGenerator.generateAndApply(_flags);
  }
}
