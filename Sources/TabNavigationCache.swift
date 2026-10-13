import AppKit

// A short-lived local bridge between Chrome's navigation events and the default-browser App.
// Every match also checks the live tab ID, window ID and exact current URL.
enum TabNavigationCache {
    struct Entry: Codable {
        let tabID: Int
        let windowID: Int
        let url: String
        let aliases: [String]
    }

    private struct Snapshot: Codable {
        let chromePID: Int32
        let chromeLaunchedAt: Double
        let entries: [Entry]
    }

    private static var directory: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Caches/ChromeTabRouter/Navigation", isDirectory: true)
    }

    private static var chrome: NSRunningApplication? {
        NSRunningApplication.runningApplications(withBundleIdentifier: "com.google.Chrome").first
    }

    static func save(_ rawEntries: Any?, sourceID: String) throws {
        guard ChromeExtensionConnection.allowedIDs().contains(sourceID),
              let data = rawEntries as? [[String: Any]], data.count <= 512,
              let browser = chrome, let launchedAt = browser.launchDate?.timeIntervalSince1970 else {
            throw RouterError(message: "导航记录格式不正确。", code: 0)
        }
        var entries: [Entry] = []
        for raw in data {
            guard let tabID = raw["tabID"] as? Int, tabID >= 0,
                  let windowID = raw["windowID"] as? Int, windowID >= 0,
                  let url = raw["url"] as? String,
                  let aliases = raw["aliases"] as? [String], aliases.count >= 2, aliases.count <= 32,
                  aliases.contains(url), aliases.allSatisfy(validURL) else {
                throw RouterError(message: "导航记录格式不正确。", code: 0)
            }
            entries.append(Entry(tabID: tabID, windowID: windowID, url: url, aliases: aliases))
        }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true,
                                                attributes: [.posixPermissions: 0o700])
        let destination = directory.appendingPathComponent("\(sourceID).json")
        let snapshot = Snapshot(chromePID: browser.processIdentifier, chromeLaunchedAt: launchedAt, entries: entries)
        let bytes = try JSONEncoder().encode(snapshot)
        guard bytes.count <= 1048576 else { throw RouterError(message: "导航记录过大。", code: 0) }
        try bytes.write(to: destination, options: [.atomic, .completeFileProtection])
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: destination.path)
    }

    static func entries() -> [Entry] {
        entries(sources: ChromeExtensionConnection.allowedIDs() + ["app"])
    }

    static func appEntries() -> [Entry] { entries(sources: ["app"]) }

    static func saveAppEntries(_ entries: [Entry]) throws {
        guard let browser = chrome, let launchedAt = browser.launchDate?.timeIntervalSince1970 else { return }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true,
                                                attributes: [.posixPermissions: 0o700])
        let destination = directory.appendingPathComponent("app.json")
        let snapshot = Snapshot(chromePID: browser.processIdentifier, chromeLaunchedAt: launchedAt,
                                entries: Array(entries.prefix(512)))
        let bytes = try JSONEncoder().encode(snapshot)
        guard bytes.count <= 1048576 else { return }
        try bytes.write(to: destination, options: [.atomic, .completeFileProtection])
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: destination.path)
    }

    private static func entries(sources: [String]) -> [Entry] {
        guard let browser = chrome, let launchedAt = browser.launchDate?.timeIntervalSince1970 else { return [] }
        return sources.flatMap { identifier -> [Entry] in
            let path = directory.appendingPathComponent("\(identifier).json")
            guard let size = (try? path.resourceValues(forKeys: [.fileSizeKey]))?.fileSize, size <= 1048576,
                  let data = try? Data(contentsOf: path),
                  let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data),
                  snapshot.chromePID == browser.processIdentifier, snapshot.chromeLaunchedAt == launchedAt else { return [] }
            return snapshot.entries
        }
    }

    static func clear() {
        for identifier in ChromeExtensionConnection.allowedIDs() + ["app"] {
            try? FileManager.default.removeItem(at: directory.appendingPathComponent("\(identifier).json"))
        }
    }

    private static func validURL(_ raw: String) -> Bool {
        guard raw.utf8.count <= 16384, let url = URL(string: raw), url.host != nil else { return false }
        return ["http", "https"].contains(url.scheme?.lowercased() ?? "")
    }
}
