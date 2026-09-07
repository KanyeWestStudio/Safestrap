import 'package:flutter/material.dart';
import 'package:flutter_floatwing/flutter_floatwing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _overlayGranted = false;
  final _fflagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _fflagsController.text = prefs.getString('fastflags') ?? '';

    try {
      final granted = await FloatwingPlugin().checkPermission();
      if (mounted) setState(() => _overlayGranted = granted);
    } catch (_) {}
  }

  Future<void> _requestOverlay() async {
    try {
      final granted = await FloatwingPlugin().checkPermission();
      if (granted) {
        setState(() => _overlayGranted = true);
        return;
      }
      await FloatwingPlugin().openPermissionSetting();
    } catch (_) {}
  }

  Future<void> _saveFlags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fastflags', _fflagsController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('FastFlags saved locally')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            leading: Icon(Icons.tune_rounded),
            title: Text('FastFlags'),
            subtitle:
                Text('ClientAppSettings.json — requires root on Android'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _fflagsController,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '{\n  "FFlagEnableX": true\n}',
              ),
            ),
          ),
          TextButton(
            onPressed: _saveFlags,
            child: const Text('Save FastFlags'),
          ),
        ],
      ),
    );
  }
}
