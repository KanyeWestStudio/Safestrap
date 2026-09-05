import 'package:flutter/material.dart';
import 'package:safestrap/screens/home_screen.dart';

class SafestrapApp extends StatelessWidget {
  const SafestrapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safestrap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A2FF), // Roblox blue
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
