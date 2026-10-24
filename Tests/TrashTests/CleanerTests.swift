import XCTest
@testable import Trash

final class CleanerTests: XCTestCase {
    func testDeletesOnlyInsideTargetsAndKeepsFolder() throws {
        let fm = FileManager.default
        let home = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let cache = home.appendingPathComponent("Library/Caches")
        let docs = home.appendingPathComponent("Documents")
        try fm.createDirectory(at: cache, withIntermediateDirectories: true)
        try fm.createDirectory(at: docs, withIntermediateDirectories: true)
        try "x".write(to: cache.appendingPathComponent("a.tmp"), atomically: true, encoding: .utf8)
        try "keep".write(to: docs.appendingPathComponent("keep.txt"), atomically: true, encoding: .utf8)
        // symlink to outside folder must be removed as a link, not followed
        try fm.createSymbolicLink(at: cache.appendingPathComponent("link"), withDestinationURL: docs)
        defer { try? fm.removeItem(at: home) }

        let r = Cleaner.run(targets: [CleanupTarget(name: "c", relativePath: "Library/Caches")], home: home)

        XCTAssertEqual(r.deletedItems, 2)
        XCTAssertEqual(r.paths.first?.name, "c")
        XCTAssertTrue(fm.fileExists(atPath: cache.path))
        XCTAssertTrue(fm.fileExists(atPath: docs.appendingPathComponent("keep.txt").path))
    }

    func testSuffixTargetOnlyDeletesMatches() throws {
        let fm = FileManager.default
        let home = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let caches = home.appendingPathComponent("Library/Caches")
        try fm.createDirectory(at: caches.appendingPathComponent("x.ShipIt"), withIntermediateDirectories: true)
        try fm.createDirectory(at: caches.appendingPathComponent("other"), withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: home) }

        let r = Cleaner.run(targets: [CleanupTarget(name: "s", relativePath: "Library/Caches", nameSuffix: ".ShipIt")], home: home)

        XCTAssertEqual(r.deletedItems, 1)
        XCTAssertTrue(fm.fileExists(atPath: caches.appendingPathComponent("other").path))
    }

    func testRejectsTargetsEscapingHome() throws {
        let fm = FileManager.default
        let root = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let home = root.appendingPathComponent("home")
        let outside = root.appendingPathComponent("outside")
        try fm.createDirectory(at: home, withIntermediateDirectories: true)
        try fm.createDirectory(at: outside, withIntermediateDirectories: true)
        try "x".write(to: outside.appendingPathComponent("f"), atomically: true, encoding: .utf8)
        defer { try? fm.removeItem(at: root) }

        let r = Cleaner.run(targets: [CleanupTarget(name: "bad", relativePath: "../outside"),
                                      CleanupTarget(name: "home", relativePath: "")], home: home)

        XCTAssertEqual(r.deletedItems, 0)
        XCTAssertTrue(fm.fileExists(atPath: outside.appendingPathComponent("f").path))
    }
}
