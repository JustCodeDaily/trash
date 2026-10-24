import Foundation

/// What one cleanup step removed.
struct PathResult: Equatable {
    let name: String
    var items = 0
    var bytes: Int64 = 0
    var failures = 0
}

struct CleanupResult: Equatable {
    var paths: [PathResult] = []
    var notes: [String] = []

    var deletedItems: Int { paths.reduce(0) { $0 + $1.items } }
    var freedBytes: Int64 { paths.reduce(0) { $0 + $1.bytes } }
    var failureCount: Int { paths.reduce(0) { $0 + $1.failures } }
}

enum Cleaner {
    /// Folder targets plus the fixed `npm cache clean --force` and `brew cleanup` commands.
    static func runAll() -> CleanupResult {
        var result = run(targets: cleanupTargets)
        result.paths.append(ToolCleanup.npmCache())
        result.paths.append(ToolCleanup.brew())
        return result
    }

    /// Deletes the direct children of each target folder and nothing else.
    /// - Targets must resolve to a folder strictly inside `home`; anything else is skipped.
    /// - A target that is itself a symlink is skipped, so a link can't redirect deletion.
    /// - Symlinks inside a target are removed as links, never followed.
    static func run(
        targets: [CleanupTarget],
        home: URL = FileManager.default.homeDirectoryForCurrentUser,
        fileManager fm: FileManager = .default
    ) -> CleanupResult {
        var result = CleanupResult()
        let homePath = home.standardizedFileURL.path

        for target in targets {
            var entry = PathResult(name: target.name)
            defer { result.paths.append(entry) }
            let folder = target.url(home: home)

            guard folder.path.hasPrefix(homePath + "/"), folder.path != homePath else {
                result.notes.append("\(target.name): outside home, skipped")
                continue
            }
            let values = try? folder.resourceValues(forKeys: [.isSymbolicLinkKey, .isDirectoryKey])
            guard values?.isDirectory == true, values?.isSymbolicLink != true else {
                continue // missing, not a folder, or a symlink
            }

            guard let children = try? fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: []) else {
                entry.failures += 1
                continue
            }

            for child in children {
                if let suffix = target.nameSuffix, !child.lastPathComponent.hasSuffix(suffix) { continue }
                // Defense in depth: the child must sit directly inside the target.
                guard child.deletingLastPathComponent().standardizedFileURL.path == folder.path else { continue }
                let size = allocatedSize(of: child, fm: fm)
                do {
                    try fm.removeItem(at: child)
                    entry.items += 1
                    entry.bytes += size
                } catch {
                    entry.failures += 1
                }
            }
        }
        return result
    }

    static func allocatedSize(of url: URL, fm: FileManager = .default) -> Int64 {
        let keys: Set<URLResourceKey> = [.totalFileAllocatedSizeKey, .isDirectoryKey, .isSymbolicLinkKey]
        func size(_ u: URL) -> Int64 {
            Int64((try? u.resourceValues(forKeys: keys).totalFileAllocatedSize) ?? 0)
        }
        let values = try? url.resourceValues(forKeys: keys)
        guard values?.isDirectory == true, values?.isSymbolicLink != true else { return size(url) }
        var total: Int64 = 0
        let e = fm.enumerator(at: url, includingPropertiesForKeys: Array(keys), options: [])
        while let item = e?.nextObject() as? URL { total += size(item) }
        return total
    }
}
