import AppKit
import Carbon

final class RoutingEngine {
    private var script: NSAppleScript?

    func route(_ url: URL) throws -> String {
        guard NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") != nil else {
            throw RouterError(message: "没有找到 Google Chrome，请先安装 Chrome。", code: 0)
        }
        let settings = RoutingSettings()
        if settings["enabled"] && !settings.excludes(url) {
            let snapshot = try invoke("tabsnapshot", [])
            let key = settings.normalized(url)
            for index in 1...max(1, snapshot.numberOfItems) {
                guard snapshot.numberOfItems >= index,
                      let record = snapshot.atIndex(index),
                      let window = record.atIndex(1),
                      let tab = record.atIndex(2),
                      let value = record.atIndex(3)?.stringValue,
                      let candidate = URL(string: value) else { continue }
                if !settings["searchAllWindows"] && record.atIndex(4)?.booleanValue != true { continue }
                if settings.normalized(candidate) == key {
                    let updateURL = settings["useIncomingURL"] && candidate.absoluteString != url.absoluteString
                    var oldPage = URLComponents(url: candidate, resolvingAgainstBaseURL: false)
                    var newPage = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    oldPage?.fragment = nil
                    newPage?.fragment = nil
                    // A changed query loads the document through navigation. A fragment change needs an explicit reload.
                    let navigationLoadsPage = updateURL && oldPage?.string != newPage?.string
                    let reload = settings["refreshReusedTabs"] && !navigationLoadsPage
                    _ = try invoke("focustab", [window, tab, NSAppleEventDescriptor(string: url.absoluteString),
                                               NSAppleEventDescriptor(boolean: updateURL), NSAppleEventDescriptor(boolean: reload)])
                    if updateURL { return "reused-updated" }
                    return settings["refreshReusedTabs"] ? "reused-refreshed" : "reused"
                }
            }
        }
        _ = try invoke("opennewtab", [NSAppleEventDescriptor(string: url.absoluteString)])
        return "opened"
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
