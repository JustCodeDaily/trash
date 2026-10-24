import AppKit
import UserNotifications

@main
enum TrashMain {
    @MainActor static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory) // menu bar only, no Dock icon
        app.run()
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private var busy = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        if Bundle.main.bundleIdentifier != nil {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
        }
        guard let button = item.button else { return }
        button.image = NSImage(systemSymbolName: "trash", accessibilityDescription: "Trash")
        button.image?.isTemplate = true
        button.toolTip = "Click to clean"
        button.target = self
        button.action = #selector(clicked)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    @objc private func clicked() {
        if NSApp.currentEvent?.type == .rightMouseUp { return showMenu() }
        clean()
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: "Quit Trash", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.menu = menu
        item.button?.performClick(nil)
        item.menu = nil
    }

    private func clean() {
        guard !busy else { return }
        busy = true
        item.button?.isEnabled = false
        Task.detached {
            let result = Cleaner.runAll()
            await MainActor.run {
                self.busy = false
                self.item.button?.isEnabled = true
                self.notify(result)
            }
        }
    }

    private func notify(_ r: CleanupResult) {
        guard Bundle.main.bundleIdentifier != nil else { return }
        func size(_ b: Int64) -> String { ByteCountFormatter.string(fromByteCount: b, countStyle: .file) }

        var lines = r.paths.map { "\($0.name): \($0.bytes > 0 ? size($0.bytes) : "nothing to clean")" }
        if r.failureCount > 0 {
            lines.append("\(r.failureCount) item(s) couldn't be removed (check Full Disk Access)")
        }
        let content = UNMutableNotificationContent()
        content.title = "Trash freed \(size(r.freedBytes))"
        content.body = lines.joined(separator: "\n")
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }
}
