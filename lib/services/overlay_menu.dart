import 'package:flutter/material.dart';
import '../screens/fflags_tab.dart';
import '../screens/sky_changer_tab.dart';
import '../screens/executor_tab.dart';
import '../screens/client_tab.dart';
import '../screens/lag_tab.dart';

// ─── Service to show/hide overlay inside the main app ───────────
class OverlayMenu {
  static OverlayEntry? _entry;

  static void show(BuildContext context) {
    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (context) => const OverlayFloatingWidget(),
    );
    Overlay.of(context).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

// ─── Public widget used for both in‑app overlay and floating window ──
class OverlayFloatingWidget extends StatefulWidget {
  const OverlayFloatingWidget({super.key});

  @override
  State<OverlayFloatingWidget> createState() => _OverlayFloatingWidgetState();
}

class _OverlayFloatingWidgetState extends State<OverlayFloatingWidget> {
  double _dx = 0, _dy = 0;
  bool _isDragging = false;
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _dx,
      top: _dy,
      child: GestureDetector(
        onPanStart: (details) => _isDragging = true,
        onPanUpdate: (details) {
          if (_isDragging) {
            setState(() {
              _dx += details.delta.dx;
              _dy += details.delta.dy;
            });
          }
        },
        onPanEnd: (details) => _isDragging = false,
        child: Container(
          key: _key,
          width: 380,
          height: 500,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1),
            boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
          ),
          child: Column(
            children: [
              // Title bar with close button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Text('Safestrap Menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: OverlayMenu.hide,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Tab bar and content
              Expanded(
                child: DefaultTabController(
                  length: 5,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: const [
                          Tab(text: 'FFlags'),
                          Tab(text: 'Sky'),
                          Tab(text: 'Executor'),
                          Tab(text: 'Client'),
                          Tab(text: 'Lag'),
                        ],
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        indicatorColor: Colors.blue,
                        indicatorSize: TabBarIndicatorSize.tab,
                        isScrollable: false,
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: const [
                            FFlagsTab(),
                            SkyChangerTab(),
                            ExecutorTab(),
                            ClientTab(),
                            LagTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
