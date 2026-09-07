import 'package:flutter/material.dart';

class SkyChangerTab extends StatelessWidget {
  const SkyChangerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud, color: Colors.white54, size: 60),
            SizedBox(height: 16),
            Text('Sky Changer (Coming Soon)', style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 8),
            Text('Select from 15 skybox themes', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
//THIS IS COMING SOON
