import AppKit

struct ChromeTabState {
    let windowID: Int
    let tabID: Int
    let url: URL
    let frontWindow: Bool
    let loading: Bool
    let incognito: Bool
}

// Observe only tabs the App has navigated. Settled records are replaced when their live URL changes.
final class AppNavigationRecords {
    private struct Pending {
        let requestedURL: String
        let retainedAliases: [String]
        let deadline: Date
        var observedURL: String?
        var stableSince: Date?
    }

    private let read: (Set<Int>) throws -> [ChromeTabState]
    private var records: [Int: TabNavigationCache.Entry]
    private var pending: [Int: Pending] = [:]
    private var privateTabs: Set<Int> = []
    private var timer: Timer?
    private var failures = 0

    init(read: @escaping (Set<Int>) throws -> [ChromeTabState]) {
        self.read = read
        records = Dictionary(TabNavigationCache.appEntries().map { ($0.tabID, $0) }, uniquingKeysWith: { _, last in last })
        schedule()
    }

    deinit { timer?.invalidate() }

    func entries(in tabs: [ChromeTabState]) -> [TabNavigationCache.Entry] {
        observe(tabs)
        var result = Array(records.values)
        for tab in tabs {
            guard let load = pending[tab.tabID] else { continue }
            let aliases = Array(Set(load.retainedAliases + [load.requestedURL, tab.url.absoluteString]))
            result.append(TabNavigationCache.Entry(tabID: tab.tabID, windowID: tab.windowID,
                                                   url: tab.url.absoluteString, aliases: aliases))
        }
        return result
    }

    func isOpening(_ tab: ChromeTabState, requestedURL: URL) -> Bool {
        pending[tab.tabID]?.requestedURL == requestedURL.absoluteString
    }

    func track(_ tab: ChromeTabState, requestedURL: URL, retaining aliases: [String] = []) {
        records.removeValue(forKey: tab.tabID)
        if tab.incognito { privateTabs.insert(tab.tabID) }
        else { privateTabs.remove(tab.tabID) }
        pending[tab.tabID] = Pending(requestedURL: requestedURL.absoluteString, retainedAliases: aliases,
                                      deadline: Date().addingTimeInterval(120))
        persist()
        schedule()
    }

    func clear() {
        records.removeAll()
        pending.removeAll()
        privateTabs.removeAll()
        timer?.invalidate()
        timer = nil
        persist()
    }

    private func observe(_ tabs: [ChromeTabState]) {
        let now = Date()
        let live = Dictionary(tabs.map { ($0.tabID, $0) }, uniquingKeysWith: { _, last in last })
        var changed = false
        for id in Array(records.keys) {
            guard let tab = live[id], let record = records[id] else {
                records.removeValue(forKey: id)
                privateTabs.remove(id)
                changed = true
                continue
            }
            if record.url != tab.url.absoluteString {
                var previous = URLComponents(string: record.url)
                var current = URLComponents(url: tab.url, resolvingAgainstBaseURL: false)
                let fragment = current?.percentEncodedFragment
                previous?.fragment = nil
                current?.fragment = nil
                if previous?.string == current?.string {
                    let aliases = record.aliases.compactMap { address -> String? in
                        var components = URLComponents(string: address)
                        components?.percentEncodedFragment = fragment
                        return components?.string
                    }
                    records[id] = TabNavigationCache.Entry(tabID: id, windowID: tab.windowID,
                                                           url: tab.url.absoluteString, aliases: aliases)
                } else {
                    records.removeValue(forKey: id)
                    privateTabs.remove(id)
                }
                changed = true
            } else if record.windowID != tab.windowID {
                records[id] = TabNavigationCache.Entry(tabID: id, windowID: tab.windowID,
                                                       url: record.url, aliases: record.aliases)
                changed = true
            }
            if tab.incognito { privateTabs.insert(id) }
            else { privateTabs.remove(id) }
        }
        for id in Array(pending.keys) {
            guard let tab = live[id], var load = pending[id] else {
                pending.removeValue(forKey: id)
                privateTabs.remove(id)
                continue
            }
            let current = tab.url.absoluteString
            if tab.loading || load.observedURL != current {
                load.stableSince = nil
            } else if load.stableSince == nil {
                load.stableSince = now
            }
            load.observedURL = current
            if !tab.loading, let since = load.stableSince, now.timeIntervalSince(since) >= 0.5 {
                let aliases = Array(Set(load.retainedAliases + [load.requestedURL, current]))
                records[id] = TabNavigationCache.Entry(tabID: id, windowID: tab.windowID, url: current, aliases: aliases)
                pending.removeValue(forKey: id)
                changed = true
            } else if now >= load.deadline {
                pending.removeValue(forKey: id)
            } else {
                pending[id] = load
            }
        }
        if changed { persist() }
    }

    private func persist() {
        try? TabNavigationCache.saveAppEntries(records.values.filter { !privateTabs.contains($0.tabID) })
    }

    private func schedule() {
        timer?.invalidate()
        timer = nil
        guard !records.isEmpty || !pending.isEmpty else { return }
        let interval = pending.isEmpty ? 3.0 : 0.25
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }
            guard !NSRunningApplication.runningApplications(withBundleIdentifier: "com.google.Chrome").isEmpty else {
                self.clear()
                TabNavigationCache.clear()
                return
            }
            do {
                self.observe(try self.read(Set(self.records.keys).union(self.pending.keys)))
                self.failures = 0
            } catch {
                self.failures += 1
                if self.failures >= 3 { self.clear(); return }
            }
            self.schedule()
        }
    }
}
