import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_floatwing/flutter_floatwing.dart';

import '../models/launch_profile.dart';
import '../services/bootstrapper_service.dart';
import '../services/config_service.dart';
import '../services/script_engine.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scriptController = TextEditingController();
  bool _overlayGranted = false;
  bool _running = false;
  LaunchProfile? _preview;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scriptController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final script = await ConfigService.loadScript();
    if (!mounted) return;
    _scriptController.text = script;

    if (!BootstrapperService.supportsOverlay) return;
    try {
      final granted = await FloatwingPlugin().checkPermission();
      if (mounted) setState(() => _overlayGranted = granted);
    } on PlatformException catch (e) {
      if (mounted) setState(() => _error = 'Overlay unavailable: ${e.message}');
    }
  }

  Future<void> _requestOverlay() async {
    try {
      if (await FloatwingPlugin().checkPermission()) {
        if (mounted) setState(() => _overlayGranted = true);
        return;
      }
      await FloatwingPlugin().openPermissionSetting();
    } on PlatformException catch (e) {
      if (mounted) setState(() => _error = 'Overlay unavailable: ${e.message}');
    }
  }

  Future<void> _runScript() async {
    setState(() => _running = true);
    try {
      final profile = await ScriptEngine.runGuarded(_scriptController.text);
      await ConfigService.saveScript(_scriptController.text);
      await ConfigService.saveProfile(profile);
      if (!mounted) return;
      setState(() {
        _preview = profile;
        _error = null;
      });
    } on ScriptException catch (e) {
      if (!mounted) return;
      setState(() {
        _preview = null;
        _error = e.message;
      });
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final error = _error;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (BootstrapperService.supportsOverlay)
            ListTile(
              leading: const Icon(Icons.layers_rounded),
              title: const Text('Overlay (draw over apps)'),
              subtitle: Text(_overlayGranted ? 'Granted' : 'Not granted'),
              trailing: Switch(
                value: _overlayGranted,
                onChanged: (_) => _requestOverlay(),
              ),
            ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.code_rounded),
            title: Text('Config script'),
            subtitle: Text(
              'Lua 5.3 script. Use fflag/fflags to set FastFlags and '
              'profile{} for the launch profile.',
            ),
          ),
          TextField(
            controller: _scriptController,
            maxLines: 14,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _running ? null : _runScript,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Run & save'),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                error,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          if (preview != null) ...[
            const SizedBox(height: 16),
            Text('Profile: ${preview.name}'),
            if (preview.placeId != null) Text('Place: ${preview.placeId}'),
            Text('Overlay: ${preview.overlay ? 'on' : 'off'}'),
            const SizedBox(height: 8),
            const Text('FastFlags'),
            Text(
              preview.fastFlagsJson,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            for (final line in preview.logs) Text('› $line'),
          ],
        ],
      ),
    );
  }
}
