import Foundation

/// The two fixed commands Trash runs. No arguments ever come from outside.
enum ToolCleanup {
    private static let home = FileManager.default.homeDirectoryForCurrentUser
    private static let fm = FileManager.default

    /// `npm cache clean --force`; reports the drop in size of ~/.npm/_cacache.
    static func npmCache() -> PathResult {
        var r = PathResult(name: "npm cache")
        guard let npm = findNpm() else { return r }
        let cache = home.appendingPathComponent(".npm/_cacache")
        let before = Cleaner.allocatedSize(of: cache)
        let env = ["PATH": npm.deletingLastPathComponent().path + ":/usr/bin:/bin"]
        guard exec(npm.path, ["cache", "clean", "--force"], env: env) else { r.failures += 1; return r }
        r.bytes = max(0, before - Cleaner.allocatedSize(of: cache))
        return r
    }

    /// `brew cleanup`; reports the drop in size of Homebrew's download cache.
    static func brew() -> PathResult {
        var r = PathResult(name: "Homebrew")
        guard let brew = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"].first(where: fm.isExecutableFile) else { return r }
        let cache = home.appendingPathComponent("Library/Caches/Homebrew")
        let before = Cleaner.allocatedSize(of: cache)
        guard exec(brew, ["cleanup"], env: ["HOME": home.path, "PATH": "/usr/bin:/bin:/usr/sbin:/sbin"]) else { r.failures += 1; return r }
        r.bytes = max(0, before - Cleaner.allocatedSize(of: cache))
        return r
    }

    /// A GUI app doesn't inherit the shell PATH, so look where npm usually lives (nvm first).
    private static func findNpm() -> URL? {
        let nvm = home.appendingPathComponent(".nvm/versions/node")
        let versions = ((try? fm.contentsOfDirectory(atPath: nvm.path)) ?? [])
            .sorted { $0.compare($1, options: .numeric) == .orderedDescending }
        let nvmNpms = versions.map { nvm.appendingPathComponent("\($0)/bin/npm").path }
        return (nvmNpms + ["/opt/homebrew/bin/npm", "/usr/local/bin/npm"])
            .first(where: fm.isExecutableFile)
            .map { URL(fileURLWithPath: $0) }
    }

    private static func exec(_ path: String, _ args: [String], env: [String: String]) -> Bool {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        p.environment = env
        p.standardOutput = FileHandle.nullDevice
        p.standardError = FileHandle.nullDevice
        do { try p.run() } catch { return false }
        p.waitUntilExit()
        return p.terminationStatus == 0
    }
}
