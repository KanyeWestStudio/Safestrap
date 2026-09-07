import 'package:flutter/material.dart';
import 'package:flutter_floatwing/flutter_floatwing.dart';

class OverlayMenu extends StatelessWidget {
  const OverlayMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xF2111318),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00A2FF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Safestrap',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Playing Roblox',
              style: TextStyle(color: Colors.greenAccent, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ListTile(
              dense: true,
              leading: const Icon(Icons.tune, color: Color(0xFF00A2FF)),
              title: const Text('FastFlags'),
              onTap: () =>
                  FloatwingPlugin().currentWindow?.launchMainActivity(),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.close, color: Colors.redAccent),
              title: const Text('Close'),
              onTap: () => FloatwingPlugin().currentWindow?.close(),
            ),
          ],
        ),
      ),
    );
  }
}
