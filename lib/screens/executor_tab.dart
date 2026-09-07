import 'package:flutter/material.dart';

class ExecutorTab extends StatelessWidget {
  const ExecutorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.code, color: Colors.white54, size: 60),
            SizedBox(height: 16),
            Text('Lua Executor (Coming Soon)', style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 8),
            Text('Execute custom Lua scripts in Roblox', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
COMING SOON
