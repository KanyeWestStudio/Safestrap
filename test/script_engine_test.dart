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

  test('rejects private server codes that are not URI safe', () {
    expect(
      () => ScriptEngine.run('profile{ private_server = "a; rm -rf ~" }'),
      throwsA(isA<ScriptException>()),
    );
    expect(
      ScriptEngine.run('profile{ private_server = "abc-123_x" }')
          .privateServerCode,
      'abc-123_x',
    );
  });

  test('runGuarded returns the profile', () async {
    final profile = await ScriptEngine.runGuarded('profile{ name = "Async" }');
    expect(profile.name, 'Async');
  });

  test('runGuarded reports script errors', () {
    expect(
      ScriptEngine.runGuarded('fflag('),
      throwsA(isA<ScriptException>()),
    );
  });

  test('runGuarded stops a script that never returns', () {
    expect(
      ScriptEngine.runGuarded(
        'while true do end',
        timeout: const Duration(milliseconds: 300),
      ),
      throwsA(isA<ScriptException>()),
    );
  });
}
