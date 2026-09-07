import 'package:flutter/material.dart';

class ClientTab extends StatelessWidget {
  const ClientTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.speed, color: Colors.white54, size: 60),
            SizedBox(height: 16),
            Text('Client Mods (Coming Soon)', style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 8),
            Text('Speed, Jump, Fly, etc.', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
//COMING SOON
