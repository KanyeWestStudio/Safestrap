import 'package:lua_dardo_plus/lua.dart';

import '../models/launch_profile.dart';

class ScriptException implements Exception {
  ScriptException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Runs a Luau-flavoured config script (Lua 5.3 VM) and collects the
/// [LaunchProfile] it declares.
///
/// Available globals:
///   fflag(name, value)          -- set a single FastFlag
///   fflags{ Name = value, ... } -- set several FastFlags
///   profile{ name =, place_id =, private_server =, overlay = }
///   log(message)
class ScriptEngine {
  static const String defaultScript = '''
-- Safestrap config script (Lua 5.3 syntax)
profile{ name = "Default", overlay = true }

fflags{
  DFIntTaskSchedulerTargetFps = 60,
  FFlagDebugGraphicsPreferVulkan = false,
}

log("profile ready")
''';

  static const List<String> _blockedGlobals = [
    'collectgarbage',
    'dofile',
    'io',
    'load',
    'loadfile',
    'os',
    'package',
    'require',
  ];

  static LaunchProfile run(String source) {
    final fastFlags = <String, Object>{};
    final logs = <String>[];
    var name = 'default';
    int? placeId;
    String? privateServerCode;
    var overlay = true;

    final state = LuaState.newState();
    state.openLibs();
    for (final global in _blockedGlobals) {
      state.pushNil();
      state.setGlobal(global);
    }

    state.pushDartFunction((ls) {
      final key = ls.checkString(1);
      if (key == null || key.isEmpty) {
        return ls.error2('fflag: expected a flag name');
      }
      final value = _readValue(ls, 2);
      if (value == null) {
        return ls.error2('fflag: unsupported value for "%s"', [key]);
      }
      fastFlags[key] = value;
      return 0;
    });
    state.setGlobal('fflag');

    state.pushDartFunction((ls) {
      ls.checkType(1, LuaType.luaTable);
      _forEachEntry(ls, 1, (key, index) {
        final value = _readValue(ls, index);
        if (value == null) {
          throw ScriptException('fflags: unsupported value for "$key"');
        }
        fastFlags[key] = value;
      });
      return 0;
    });
    state.setGlobal('fflags');

    state.pushDartFunction((ls) {
      ls.checkType(1, LuaType.luaTable);
      _forEachEntry(ls, 1, (key, index) {
        switch (key) {
          case 'name':
            name = ls.toStr(index) ?? name;
          case 'place_id':
            placeId = ls.toIntegerX(index);
          case 'private_server':
            privateServerCode = ls.toStr(index);
          case 'overlay':
            overlay = ls.toBoolean(index);
          default:
            throw ScriptException('profile: unknown field "$key"');
        }
      });
      return 0;
    });
    state.setGlobal('profile');

    state.pushDartFunction((ls) {
      logs.add(ls.toString2(1) ?? '');
      return 0;
    });
    state.setGlobal('log');

    try {
      if (state.loadString(source) != ThreadStatus.luaOk) {
        throw ScriptException(state.toStr(-1) ?? 'syntax error');
      }
      if (state.pCall(0, 0, 0) != ThreadStatus.luaOk) {
        throw ScriptException(state.toStr(-1) ?? 'script error');
      }
    } on ScriptException {
      rethrow;
    } on Exception catch (e) {
      throw ScriptException('$e');
    }

    return LaunchProfile(
      name: name,
      fastFlags: fastFlags,
      placeId: placeId,
      privateServerCode: privateServerCode,
      overlay: overlay,
      logs: logs,
    );
  }

  /// Calls [onEntry] for each string key of the table at [tableIndex], with the
  /// stack index holding the corresponding value.
  static void _forEachEntry(
    LuaState ls,
    int tableIndex,
    void Function(String key, int valueIndex) onEntry,
  ) {
    ls.pushNil();
    while (ls.next(tableIndex)) {
      final key = ls.toStr(-2);
      if (key == null) {
        throw ScriptException('expected string keys');
      }
      onEntry(key, ls.getTop());
      ls.pop(1);
    }
  }

  static Object? _readValue(LuaState ls, int index) {
    switch (ls.type(index)) {
      case LuaType.luaBoolean:
        return ls.toBoolean(index);
      case LuaType.luaNumber:
        return ls.isInteger(index) ? ls.toInteger(index) : ls.toNumber(index);
      case LuaType.luaString:
        return ls.toStr(index);
      default:
        return null;
    }
  }
}
