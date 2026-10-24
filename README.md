# Trash

A tiny macOS app: one click on **Clean** deletes the contents of the folders listed in
`cleanupTargets` (`Sources/Trash/CleanupTargets.swift`) — and nothing else.

Safety rules (enforced in `Cleaner.swift`, covered by tests):
- Only direct children of listed folders are deleted; the folders themselves stay.
- Targets must resolve inside the home folder (no `..` escapes, never home itself).
- Symlinks are never followed; they are removed as links.

Defaults: Chrome/node-gyp/dotslash/Gemini caches, `*.ShipIt` update leftovers, `~/.npm`, `~/Library/Logs`, Xcode DerivedData, `~/.Trash`. Edit the array to change them.
Clean also runs the fixed command `brew cleanup` if Homebrew is installed.

Terminal equivalent: `./scripts/clean.zsh`.

Build: `./scripts/build-app.sh` → `build/Trash.app`. Test: `swift test`.
`~/.Trash` and some caches need Full Disk Access (System Settings → Privacy & Security).
