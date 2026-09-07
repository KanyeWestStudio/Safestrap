# Safestrap

**Safe multi-platform Roblox bootstrapper** built with Flutter.

## Goals
- Clean & secure launcher for Roblox
- Runs on Android, iOS, Windows, Linux, and macOS
- Safe FastFlag support
- Modern dark UI
- Lua/Luau config scripting

## Status
Early development

## Config scripts

The launch profile and the FastFlags Safestrap applies are produced by a Lua
script (Luau-flavoured syntax on a Lua 5.3 VM, so Luau type annotations are not
supported). Edit it in Settings → Config script; it runs on every launch.

```lua
profile{ name = "Perf", place_id = 1818, overlay = true }

fflags{
  DFIntTaskSchedulerTargetFps = 120,
  FFlagDebugGraphicsPreferVulkan = true,
}

local fps = 60
for _ = 1, 2 do fps = fps + 30 end
fflag("DFIntTaskSchedulerTargetFps", fps)

log("profile ready")
```

Globals available to a script:

| Global | Purpose |
| --- | --- |
| `fflag(name, value)` | set one FastFlag (bool, number or string) |
| `fflags{ Name = value, ... }` | set several FastFlags |
| `profile{ name, place_id, private_server, overlay }` | launch profile |
| `log(message)` | message shown in the script output |

`io`, `os`, `package`, `require`, `load`, `loadfile` and `dofile` are removed
from the sandbox, so scripts can compute values but cannot touch the device.

FastFlags are written to `ClientAppSettings.json` of a desktop Roblox install
(Windows, macOS, Sober on Linux). Android sandboxes the Roblox data directory,
so flags there are stored in the profile only.

## Getting Started

```bash
flutter pub get
flutter test
flutter run
```
