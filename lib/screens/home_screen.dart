import 'package:flutter/material.dart';
import 'package:safestrap/services/launcher_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLaunching = false;

  Future<void> _launch() async {
    setState(() => _isLaunching = true);

    final success = await LauncherService.launchRoblox();

    if (mounted) {
      setState(() => _isLaunching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Roblox launched!' : 'Failed to launch Roblox'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safestrap'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rocket_launch_rounded,
              size: 90,
              color: Color(0xFF00A2FF),
            ),
            const SizedBox(height: 24),
            const Text(
              'Safestrap',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Safe Roblox Bootstrapper',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _isLaunching ? null : _launch,
              icon: _isLaunching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(_isLaunching ? 'Launching...' : 'Launch Roblox'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
