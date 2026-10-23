import AppKit
import Carbon

final class RoutingEngine {
    private var script: NSAppleScript?
    private lazy var appNavigation = AppNavigationRecords { [weak self] identifiers in
        guard let self else { return [] }
        let ids = NSAppleEventDescriptor.list()
        for (index, identifier) in identifiers.sorted().enumerated() {
            ids.insert(NSAppleEventDescriptor(string: String(identifier)), at: index + 1)
        }
        return self.tabs(from: try self.invoke("trackedtabsnapshot", [ids]))
    }

    func browserTerminated() { appNavigation.clear() }

    func route(_ url: URL) throws -> String {
        guard NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") != nil else {
            throw RouterError(message: "没有找到 Google Chrome，请先安装 Chrome。", code: 0)
        }
        let settings = RoutingSettings()
        if settings["enabled"] && !settings.excludes(url) {
            let snapshot = tabs(from: try invoke("tabsnapshot", []))
            let key = settings.normalized(url)
            let navigationEntries = appNavigation.entries(in: snapshot) + TabNavigationCache.entries()
            for tab in snapshot {
                let candidate = tab.url
                if !settings["searchAllWindows"] && !tab.frontWindow { continue }
                let redirectMatch = navigationEntries.contains { entry in
                    entry.tabID == tab.tabID && entry.windowID == tab.windowID &&
                    entry.url == candidate.absoluteString && entry.aliases.contains { raw in
                        guard let address = URL(string: raw), !settings.excludes(address) else { return false }
                        return settings.normalized(address) == key
                    }
                }
                if !settings.excludes(candidate) && (settings.normalized(candidate) == key || redirectMatch) {
                    let inFlight = appNavigation.isOpening(tab, requestedURL: url)
                    let (updateURL, reload) = settings.reuseAction(currentURL: candidate, incomingURL: url,
                                                                 isOpening: inFlight)
                    let focused = try invoke("focustab", [NSAppleEventDescriptor(int32: Int32(tab.windowID)),
                        NSAppleEventDescriptor(string: String(tab.tabID)), NSAppleEventDescriptor(string: url.absoluteString),
                        NSAppleEventDescriptor(boolean: updateURL), NSAppleEventDescriptor(boolean: reload)])
                    if (updateURL || reload), let state = tabState(from: focused) {
                        let retained = reload ? navigationEntries.filter {
                            $0.tabID == tab.tabID && $0.url == candidate.absoluteString
                        }.flatMap(\.aliases).compactMap { address -> String? in
                            guard updateURL else { return address }
                            var alias = URLComponents(string: address)
                            alias?.percentEncodedFragment = URLComponents(url: url, resolvingAgainstBaseURL: false)?.percentEncodedFragment
                            return alias?.string
                        } : []
                        appNavigation.track(state, requestedURL: updateURL ? url : candidate, retaining: retained)
                    }
                    if updateURL { return "reused-updated" }
                    return reload ? "reused-refreshed" : "reused"
                }
            }
        }
        let opened = try invoke("opennewtab", [NSAppleEventDescriptor(string: url.absoluteString)])
        if let tab = tabState(from: opened) { appNavigation.track(tab, requestedURL: url) }
        return "opened"
    }

    private func tabs(from descriptor: NSAppleEventDescriptor) -> [ChromeTabState] {
        guard descriptor.numberOfItems > 0 else { return [] }
        return (1...descriptor.numberOfItems).compactMap { index in
            descriptor.atIndex(index).flatMap(tabState)
        }
    }

    private func tabState(from record: NSAppleEventDescriptor) -> ChromeTabState? {
        guard let window = record.atIndex(1), let tab = record.atIndex(2),
              let value = record.atIndex(3)?.stringValue, let url = URL(string: value),
              ["http", "https"].contains(url.scheme?.lowercased() ?? ""), url.host != nil else { return nil }
        let windowID = window.stringValue.flatMap(Int.init) ?? Int(window.int32Value)
        let tabID = tab.stringValue.flatMap(Int.init) ?? Int(tab.int32Value)
        return ChromeTabState(windowID: windowID, tabID: tabID, url: url,
                              frontWindow: record.atIndex(4)?.booleanValue == true,
                              loading: record.atIndex(5)?.booleanValue == true,
                              incognito: record.atIndex(6)?.stringValue == "incognito")
    }

    private func invoke(_ handler: String, _ arguments: [NSAppleEventDescriptor]) throws -> NSAppleEventDescriptor {
        if script == nil {
            guard let scriptURL = Bundle.main.url(forResource: "ChromeRouter", withExtension: "scpt") else {
                throw RouterError(message: "应用文件不完整，请重新安装。", code: 0)
            }
            var error: NSDictionary?
            script = NSAppleScript(contentsOf: scriptURL, error: &error)
            guard script != nil else { throw scriptError(error) }
        }
        let event = NSAppleEventDescriptor(
            eventClass: AEEventClass(kASAppleScriptSuite), eventID: AEEventID(kASSubroutineEvent),
            targetDescriptor: nil, returnID: AEReturnID(kAutoGenerateReturnID), transactionID: AETransactionID(kAnyTransactionID)
        )
        event.setParam(NSAppleEventDescriptor(string: handler), forKeyword: AEKeyword(keyASSubroutineName))
        let parameters = NSAppleEventDescriptor.list()
        for (index, argument) in arguments.enumerated() { parameters.insert(argument, at: index + 1) }
        event.setParam(parameters, forKeyword: AEKeyword(keyDirectObject))
        var error: NSDictionary?
        let response = script!.executeAppleEvent(event, error: &error)
        if let error { throw scriptError(error) }
        return response
    }

    private func scriptError(_ error: NSDictionary?) -> RouterError {
        RouterError(message: error?[NSAppleScript.errorMessage] as? String ?? "无法控制 Chrome。",
                    code: error?[NSAppleScript.errorNumber] as? Int ?? 0)
    }
}
