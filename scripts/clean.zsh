#!/bin/zsh
# Same cleanup as the Trash app, from the terminal. (N) = ignore unmatched globs.
rm -rf ~/Library/Caches/Google ~/Library/Caches/*.ShipIt(N) ~/Library/Caches/node-gyp ~/Library/Caches/dotslash ~/Library/Caches/com.google.GeminiMacOS ~/.npm ~/Library/Logs/* ~/Library/Developer/Xcode/DerivedData/*(N) ~/.Trash/*(N); brew cleanup
