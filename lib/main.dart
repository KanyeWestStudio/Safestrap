import 'package:flutter/material.dart';
import 'package:flutter_floatwing/flutter_floatwing.dart';

import 'app.dart';
import 'services/overlay_menu.dart'; // contains OverlayFloatingWidget

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafestrapApp());
}

/// Entry point for the floating overlay window (Android only)
@pragma('vm:entry-point')
void overlayMain() {
  runApp(
    const OverlayFloatingWidget().floatwing(
      app: true, // makes it a system overlay
    ),
  );
}
