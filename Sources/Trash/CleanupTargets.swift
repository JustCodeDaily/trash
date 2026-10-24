import Foundation

/// A folder whose *contents* are cleaned. The folder itself is never removed.
struct CleanupTarget: Identifiable, Equatable {
    let name: String
    /// Path relative to the user's home directory.
    let relativePath: String

    var id: String { relativePath }

    func url(home: URL = FileManager.default.homeDirectoryForCurrentUser) -> URL {
        home.appendingPathComponent(relativePath, isDirectory: true).standardizedFileURL
    }
}

/// The ONLY places Trash will ever delete from. Edit this array to change
/// what "Clean" does; nothing outside these folders is ever touched.
let cleanupTargets: [CleanupTarget] = [
    CleanupTarget(name: "User Caches", relativePath: "Library/Caches"),
    CleanupTarget(name: "User Logs", relativePath: "Library/Logs"),
    CleanupTarget(name: "Trash Bin", relativePath: ".Trash"),
]
