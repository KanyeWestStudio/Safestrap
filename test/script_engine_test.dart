import 'package:flutter_test/flutter_test.dart';
import 'package:safestrap/services/script_engine.dart';

void main() {
  test('collects FastFlags and profile fields', () {
    final profile = ScriptEngine.run('''
profile{ name = "Perf", place_id = 1818, overlay = false }
fflag("DFIntTaskSchedulerTargetFps", 120)
fflags{ FFlagDebugGraphicsPreferVulkan = true, FStringTest = "x" }
log("done")
''');

    expect(profile.name, 'Perf');
    expect(profile.placeId, 1818);
    expect(profile.overlay, isFalse);
    expect(profile.fastFlags, {
      'DFIntTaskSchedulerTargetFps': 120,
      'FFlagDebugGraphicsPreferVulkan': true,
      'FStringTest': 'x',
    });
    expect(profile.logs, ['done']);
  });

  test('flags can be computed', () {
    final profile = ScriptEngine.run('''
local fps = 30
for i = 1, 2 do fps = fps * 2 end
fflag("DFIntTaskSchedulerTargetFps", fps)
''');

    expect(profile.fastFlags['DFIntTaskSchedulerTargetFps'], 120);
  });

  test('reports syntax errors', () {
    expect(
      () => ScriptEngine.run('fflag('),
      throwsA(isA<ScriptException>()),
    );
  });

  test('the default script runs', () {
    expect(ScriptEngine.run(ScriptEngine.defaultScript).name, 'Default');
  });

  test('io and os are not reachable', () {
    expect(
      () => ScriptEngine.run('io.write("x")'),
      throwsA(isA<ScriptException>()),
    );
  });
}
