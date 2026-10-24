import Foundation

/// Runs the fixed command `brew cleanup` (no user-supplied arguments), if Homebrew is installed.
enum BrewCleanup {
    static let candidates = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]

    /// Returns nil on success or when Homebrew isn't installed; otherwise a failure message.
    static func run() -> String? {
        guard let brew = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else { return nil }
        let p = Process()
        p.executableURL = URL(fileURLWithPath: brew)
        p.arguments = ["cleanup"]
        p.standardOutput = FileHandle.nullDevice
        p.standardError = FileHandle.nullDevice
        do {
            try p.run()
            p.waitUntilExit()
            return p.terminationStatus == 0 ? nil : "brew cleanup exited with \(p.terminationStatus)"
        } catch {
            return "brew cleanup: \(error.localizedDescription)"
        }
    }
}
