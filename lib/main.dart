import 'package:flutter/material.dart';
import 'package:flutter_floatwing/flutter_floatwing.dart';

import 'app.dart';                     // Your main app widget
import 'services/overlay_widget.dart'; // The new overlay UI (we'll create this)

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafestrapApp());
}

/// Entry point for the floating overlay window (Android only)
@pragma('vm:entry-point')
void overlayMain() {
  // This runs as a separate isolate/process – it must build the overlay UI
  runApp(
    const OverlayFloatingWidget().floatwing(
      app: true,          // Makes it a system overlay window
    ),
  );
}
