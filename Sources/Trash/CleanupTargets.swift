import Foundation

/// A folder whose *contents* are cleaned. The folder itself is never removed.
struct CleanupTarget: Identifiable, Equatable {
    let name: String
    /// Path relative to the user's home directory.
    let relativePath: String
    /// When set, only children whose name ends with this suffix are deleted.
    var nameSuffix: String? = nil

    var id: String { relativePath + (nameSuffix ?? "") }

    func url(home: URL = FileManager.default.homeDirectoryForCurrentUser) -> URL {
        home.appendingPathComponent(relativePath, isDirectory: true).standardizedFileURL
    }
}

/// The ONLY places Trash will ever delete from. Edit this array to change
/// what "Clean" does; nothing outside these folders is ever touched.
let cleanupTargets: [CleanupTarget] = [
    CleanupTarget(name: "Chrome cache", relativePath: "Library/Caches/Google"),
    CleanupTarget(name: "App update leftovers", relativePath: "Library/Caches", nameSuffix: ".ShipIt"),
    CleanupTarget(name: "node-gyp headers", relativePath: "Library/Caches/node-gyp"),
    CleanupTarget(name: "DotSlash binaries", relativePath: "Library/Caches/dotslash"),
    CleanupTarget(name: "Gemini cache", relativePath: "Library/Caches/com.google.GeminiMacOS"),
    CleanupTarget(name: "npm cache", relativePath: ".npm"),
    CleanupTarget(name: "User logs", relativePath: "Library/Logs"),
    CleanupTarget(name: "Xcode DerivedData", relativePath: "Library/Developer/Xcode/DerivedData"),
    CleanupTarget(name: "Trash bin", relativePath: ".Trash"),
]
