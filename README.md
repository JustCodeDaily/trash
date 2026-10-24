# Trash

A tiny macOS app: one click on **Clean** deletes the contents of the folders listed in
`cleanupTargets` (`Sources/Trash/CleanupTargets.swift`) — and nothing else.

Safety rules (enforced in `Cleaner.swift`, covered by tests):
- Only direct children of listed folders are deleted; the folders themselves stay.
- Targets must resolve inside the home folder (no `..` escapes, never home itself).
- Symlinks are never followed; they are removed as links.

Defaults: `~/Library/Caches`, `~/Library/Logs`, `~/.Trash`. Edit the array to change them.

Build: `./scripts/build-app.sh` → `build/Trash.app`. Test: `swift test`.
`~/.Trash` and some caches need Full Disk Access (System Settings → Privacy & Security).
