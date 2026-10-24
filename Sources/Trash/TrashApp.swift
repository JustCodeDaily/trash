import SwiftUI

@main
struct TrashApp: App {
    var body: some Scene {
        WindowGroup("Trash") {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @State private var result: CleanupResult?
    @State private var working = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "trash")
                .font(.system(size: 44))
            Text("Trash").font(.largeTitle.bold())

            VStack(alignment: .leading, spacing: 4) {
                Text("Only these folders are cleaned:").font(.caption).foregroundStyle(.secondary)
                ForEach(cleanupTargets) { t in
                    Text("• ~/\(t.relativePath)").font(.system(.caption, design: .monospaced))
                }
                Text("• brew cleanup").font(.system(.caption, design: .monospaced))
            }

            Button(action: clean) {
                Text(working ? "Cleaning…" : "Clean").frame(width: 160)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .disabled(working)

            if let r = result {
                VStack(spacing: 2) {
                    Text("Deleted \(r.deletedItems) items, freed " +
                         ByteCountFormatter.string(fromByteCount: r.freedBytes, countStyle: .file))
                    if !r.failures.isEmpty {
                        Text("\(r.failures.count) could not be removed (some folders need Full Disk Access)")
                            .foregroundStyle(.orange)
                    }
                }
                .font(.callout)
            }
        }
        .padding(28)
        .frame(minWidth: 360)
    }

    private func clean() {
        working = true
        Task.detached {
            var r = Cleaner.run(targets: cleanupTargets)
            if let failure = BrewCleanup.run() { r.failures.append(failure) }
            await MainActor.run { result = r; working = false }
        }
    }
}
