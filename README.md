# Trash

A menu bar app (trash icon, top right). **Click it once and it cleans** — no window, no confirmation —
then a notification shows how much was freed on each path. Right-click for Quit.
It does not launch at login and has no Dock icon.

## What it removes (and nothing else)
Folder contents listed in `cleanupTargets` (`Sources/Trash/CleanupTargets.swift`):
`~/Library/Caches/Google`, `~/Library/Caches/*.ShipIt`, `~/Library/Caches/node-gyp`,
`~/Library/Caches/com.google.GeminiMacOS`, `~/Library/Logs/*`,
`~/Library/Developer/Xcode/DerivedData/*`, `~/.Trash/*`
plus the fixed commands `npm cache clean --force` and `brew cleanup`.

Safety (enforced in `Cleaner.swift`, covered by tests): only direct children of listed folders are
deleted; targets must resolve inside the home folder; symlinks are never followed.

## Build / test
`./scripts/build-app.sh` → `build/Trash.app` (drag to Applications). `swift test` runs the tests.
`~/.Trash` and some caches need Full Disk Access (System Settings → Privacy & Security).
Terminal equivalent: `./scripts/clean.zsh`.
