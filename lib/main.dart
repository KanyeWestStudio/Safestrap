import 'package:flutter/material.dart';
import 'package:flutter_floatwing/flutter_floatwing.dart';

import 'app.dart';
import 'overlay_menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafestrapApp());
}

@pragma('vm:entry-point')
void overlayMain() {
  runApp(const OverlayMenu().floatwing(app: true));
}
