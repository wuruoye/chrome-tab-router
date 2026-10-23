import AppKit
import Carbon
import ServiceManagement

let appName = "Chrome Tab Router"
let chromeBundleID = "com.google.Chrome"
let supportedSchemes = ["http", "https"]

if CommandLine.arguments.contains("--native-host") { runNativeHost() }
if let index = CommandLine.arguments.firstIndex(of: "--connect-extension"), CommandLine.arguments.count > index + 1 {
    do {
        try connectExtension(CommandLine.arguments[index + 1])
        print("Chrome 扩展本地连接配置已更新。")
        exit(0)
    } catch { fputs("\(error)\n", stderr); exit(1) }
}

func handlerID(for scheme: String) -> String? {
    guard let link = URL(string: "\(scheme)://example.invalid/"),
          let application = NSWorkspace.shared.urlForApplication(toOpen: link) else { return nil }
    return Bundle(url: application)?.bundleIdentifier
}

if CommandLine.arguments.contains("--status") {
    let handlers = Dictionary(uniqueKeysWithValues: supportedSchemes.map {
        ($0, handlerID(for: $0) ?? "")
    })
    let data = try JSONSerialization.data(withJSONObject: handlers, options: [.prettyPrinted, .sortedKeys])
    print(String(decoding: data, as: UTF8.self))
    exit(0)
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private var statusMenuItem: NSMenuItem?
    private var resultMenuItem: NSMenuItem?
    private var defaultMenuItem: NSMenuItem?
    private var restoreMenuItem: NSMenuItem?
    private let routingEngine = RoutingEngine()
    private var settingMenuItems: [String: NSMenuItem] = [:]
    private var loginMenuItem: NSMenuItem?
    private var extensionMenuItem: NSMenuItem?
    private var exclusionsMenu: NSMenu?
    private var menuRequested = false
    private var extensionConfigurationError: String?
    private var pendingURLs: [URL] = []
    private var isRouting = false
    private var isChangingDefault = false
    private let preferences = UserDefaults.standard
    private var lastResult = "等待打开链接。"
    private let log = Logger()

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self, andSelector: #selector(receiveURL(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL)
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(browserTerminated(_:)),
            name: NSWorkspace.didTerminateApplicationNotification, object: nil
        )
        do { try registerNativeHost() }
        catch { extensionConfigurationError = error.localizedDescription }
        buildMenu()
        if CommandLine.arguments.contains("--setup") || menuRequested {
            menuRequested = false
            DispatchQueue.main.async { self.showMenu(nil) }
        }
        if !pendingURLs.isEmpty {
            processNextURL()
        }
        if CommandLine.arguments.contains("--make-default") {
            makeDefault(nil)
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showMenu(nil)
        return true
    }

    @objc private func browserTerminated(_ notification: Notification) {
        if (notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?
            .bundleIdentifier == chromeBundleID {
            routingEngine.browserTerminated()
            TabNavigationCache.clear()
        }
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        updateStatus()
    }

    @objc private func receiveURL(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        guard let value = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: value) else { return }
        if url.scheme?.lowercased() == "chrometabrouter" {
            if url.host == "connect" {
                let identifier = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?
                    .first(where: { $0.name == "extensionID" })?.value ?? ""
                do {
                    guard identifier.range(of: "^[a-p]{32}$", options: .regularExpression) != nil else {
                        throw RouterError(message: "扩展连接请求中的 ID 无效。", code: 0)
                    }
                    if identifier != ChromeExtensionConnection.storeID,
                       preferences.string(forKey: "chromeExtensionID") != identifier {
                        let alert = NSAlert()
                        alert.messageText = "连接此开发版扩展？"
                        alert.informativeText = "请确认你刚刚在 Chrome Tab Router 扩展弹窗中点击了修复连接。商店扩展会保持自动连接。\n\n开发版扩展 ID：\(identifier)"
                        alert.addButton(withTitle: "连接")
                        alert.addButton(withTitle: "取消")
                        NSApp.activate(ignoringOtherApps: true)
                        guard alert.runModal() == .alertFirstButtonReturn else { return }
                    }
                    try connectExtension(identifier)
                    extensionConfigurationError = nil
                    lastResult = "本地连接已配置，请在扩展弹窗中重新检测。"
                    showMenu(nil)
                } catch {
                    showMessage("扩展连接未完成", (error as? RouterError)?.message ?? error.localizedDescription)
                }
            }
            if url.host == "settings" { showMenu(nil) }
            if url.host == "make-default" { makeDefault(nil) }
            if url.host == "restore-default" { restoreDefault(nil) }
            return
        }
        enqueue(url)
    }

    private func enqueue(_ url: URL) {
        guard let scheme = url.scheme?.lowercased(), supportedSchemes.contains(scheme),
              url.host != nil else {
            showMessage("链接无法打开", "请使用完整的 http 或 https 链接。")
            return
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        let normalizedHost = components?.host?.lowercased()
        components?.host = normalizedHost
        if components?.path.isEmpty == true { components?.path = "/" }
        if (scheme == "http" && components?.port == 80) || (scheme == "https" && components?.port == 443) {
            components?.port = nil
        }
        pendingURLs.append(components?.url ?? url)
        if statusItem != nil { processNextURL() }
    }

    private func processNextURL() {
        guard !isRouting, !pendingURLs.isEmpty else { return }
        isRouting = true
        let url = pendingURLs.removeFirst()
        DispatchQueue.main.async { [self] in
            do {
                let result = try route(url)
                switch result {
                case "reused-updated": lastResult = "已复用原标签页并加载完整新链接。"
                case "reused-refreshed": lastResult = "已切换到已有标签页并刷新。"
                case "reused": lastResult = "已切换到已有标签页。"
                default: lastResult = "已在 Chrome 新开标签页。"
                }
                log.write(result)
            } catch {
                log.write("routing-failed")
                handleRoutingError(error, url: url)
            }
            isRouting = false
            updateStatus()
            processNextURL()
        }
    }

    private func route(_ url: URL) throws -> String {
        try routingEngine.route(url)
    }

    private func handleRoutingError(_ error: Error, url: URL) {
        let routerError = error as? RouterError
        let alert = NSAlert()
        alert.messageText = "链接尚未打开"
        if routerError?.code == -1743 {
            alert.informativeText = "请在系统设置的“隐私与安全性 → 自动化”中，允许 Chrome Tab Router 控制 Google Chrome，然后重新打开这个链接。"
            alert.addButton(withTitle: "打开自动化设置")
        } else {
            alert.informativeText = routerError?.message ?? error.localizedDescription
            alert.addButton(withTitle: "重试")
        }
        alert.addButton(withTitle: "直接用 Chrome 打开")
        alert.addButton(withTitle: "取消")
        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if routerError?.code == -1743 { openAutomationSettings(nil) }
            else { pendingURLs.insert(url, at: 0) }
        } else if response == .alertSecondButtonReturn {
            openDirectlyInChrome(url)
        }
        lastResult = "打开链接时遇到问题，可以重新打开链接重试。"
    }

    private func openDirectlyInChrome(_ url: URL) {
        guard let chrome = NSWorkspace.shared.urlForApplication(withBundleIdentifier: chromeBundleID) else { return }
        NSWorkspace.shared.open([url], withApplicationAt: chrome, configuration: NSWorkspace.OpenConfiguration())
    }

    private func buildMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", accessibilityDescription: appName)
        statusItem.button?.toolTip = appName
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.delegate = self
        addLabel(appName, to: menu)
        statusMenuItem = addLabel("", to: menu)
        resultMenuItem = addLabel(lastResult, to: menu)
        menu.addItem(.separator())
        addSetting("enabled", title: "启用标签页复用", to: menu)
        addSetting("searchAllWindows", title: "在所有 Chrome 窗口中查找", to: menu)
        addSetting("interceptBrowserLinks", title: "接管 Chrome 网页的新标签页链接", to: menu)

        let matching = addSubmenu("网址匹配", to: menu)
        addLabel("决定哪些链接可以复用同一标签页", to: matching)
        matching.addItem(.separator())
        addSetting("ignoreFragments", title: "忽略页面锚点（# 后的内容）", to: matching)
        addSetting("ignoreQueryParameters", title: "忽略所有查询参数（? 后的内容）", to: matching)
        addSetting("ignoreTrackingParameters", title: "忽略常见跟踪参数（utm_、gclid 等）", to: matching)
        let reuse = addSubmenu("复用后的操作", to: menu)
        addLabel("找到匹配的标签页后", to: reuse)
        reuse.addItem(.separator())
        addSetting("useIncomingURL", title: "更新为完整新链接并加载", to: reuse)
        addSetting("refreshReusedTabs", title: "链接不变时也刷新", to: reuse)
        settingMenuItems["useIncomingURL"]?.toolTip = "使用收到的完整网址，包括匹配时忽略的参数和 # 后内容。仅 # 后内容变化时也重新加载；关闭后保留原网址。"
        settingMenuItems["refreshReusedTabs"]?.toolTip = "完整网址相同，或关闭更新新链接时，重新加载标签页当前网址。"
        exclusionsMenu = addSubmenu("例外网站", to: menu)
        loginMenuItem = addItem("登录时自动启动", action: #selector(changeLoginSetting(_:)), to: menu)
        menu.addItem(.separator())

        let browser = addSubmenu("默认浏览器", to: menu)
        defaultMenuItem = addItem("设为默认浏览器", action: #selector(makeDefault(_:)), to: browser)
        restoreMenuItem = addItem("恢复原来的默认浏览器", action: #selector(restoreDefault(_:)), to: browser)
        let chromeExtension = addSubmenu("Chrome 扩展", to: menu)
        extensionMenuItem = addLabel("", to: chromeExtension)
        addItem("安装 Chrome 扩展…", action: #selector(installChromeExtension(_:)), to: chromeExtension)
        addItem("修复自动连接", action: #selector(repairChromeExtension(_:)), to: chromeExtension)
        addItem("打开扩展目录…", action: #selector(openExtensionDirectory(_:)), to: chromeExtension)
        addItem("安装与连接说明…", action: #selector(connectChromeExtension(_:)), to: chromeExtension)
        addItem("隐私政策…", action: #selector(openPrivacyPolicy(_:)), to: chromeExtension)
        addItem("打开 Chrome 自动化权限设置…", action: #selector(openAutomationSettings(_:)), to: menu)
        addItem("打开剪贴板中的链接", action: #selector(openClipboard(_:)), to: menu)
        menu.addItem(.separator())
        addItem("退出", action: #selector(quit(_:)), to: menu)
        statusItem.menu = menu
        updateStatus()
    }

    @discardableResult
    private func addItem(_ title: String, action: Selector, to menu: NSMenu) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        menu.addItem(item)
        return item
    }

    @discardableResult
    private func addLabel(_ title: String, to menu: NSMenu) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
        return item
    }

    private func addSubmenu(_ title: String, to menu: NSMenu) -> NSMenu {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: title)
        submenu.autoenablesItems = false
        item.submenu = submenu
        menu.addItem(item)
        return submenu
    }

    private func addSetting(_ key: String, title: String, to menu: NSMenu) {
        let item = addItem(title, action: #selector(changeSetting(_:)), to: menu)
        item.representedObject = key
        settingMenuItems[key] = item
    }

    @objc private func showMenu(_ sender: Any?) {
        guard let button = statusItem?.button else {
            menuRequested = true
            return
        }
        updateStatus()
        NSApp.activate(ignoringOtherApps: true)
        button.performClick(nil)
    }

    private func updateStatus() {
        preferences.synchronize()
        let ownID = Bundle.main.bundleIdentifier
        let isDefault = supportedSchemes.allSatisfy { handlerID(for: $0) == ownID }
        statusMenuItem?.title = isDefault ? "已设为系统默认浏览器" : "尚未设为系统默认浏览器"
        defaultMenuItem?.isEnabled = !isDefault && !isChangingDefault
        restoreMenuItem?.isEnabled = preferences.dictionary(forKey: "previousHandlers") != nil && !isChangingDefault
        resultMenuItem?.title = lastResult
        let settings = RoutingSettings()
        for (key, item) in settingMenuItems { item.state = settings[key] ? .on : .off }
        settingMenuItems["ignoreTrackingParameters"]?.isEnabled = !settings["ignoreQueryParameters"]
        loginMenuItem?.state = [.enabled, .requiresApproval].contains(SMAppService.mainApp.status) ? .on : .off
        if extensionConfigurationError != nil {
            extensionMenuItem?.title = "自动连接需要修复"
        } else if preferences.double(forKey: "chromeExtensionLastContact") > 0 {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let contact = Date(timeIntervalSince1970: preferences.double(forKey: "chromeExtensionLastContact"))
            extensionMenuItem?.title = "自动连接已配置 · 上次连接 \(formatter.string(from: contact))"
        } else {
            extensionMenuItem?.title = "自动连接已配置"
        }
        extensionMenuItem?.toolTip = "商店扩展安装后会自动连接。可在 Chrome 扩展弹窗中重新检测。"
        updateExclusionsMenu(settings.excludedDomains)
    }

    @objc private func changeSetting(_ sender: NSMenuItem) {
        guard let key = sender.representedObject as? String else { return }
        preferences.set(!RoutingSettings()[key], forKey: "routing.\(key)")
        preferences.synchronize()
        updateStatus()
    }

    private func updateExclusionsMenu(_ domains: [String]) {
        guard let menu = exclusionsMenu else { return }
        menu.removeAllItems()
        addLabel("这些网站及其子域名每次新开标签页", to: menu)
        addItem("添加网站…", action: #selector(addExcludedDomain(_:)), to: menu)
        menu.addItem(.separator())
        if domains.isEmpty {
            addLabel("暂无例外网站", to: menu)
        } else {
            for domain in domains {
                let item = addItem("移除 \(domain)", action: #selector(removeExcludedDomain(_:)), to: menu)
                item.representedObject = domain
            }
        }
    }

    @objc private func addExcludedDomain(_ sender: Any?) {
        let alert = NSAlert()
        alert.messageText = "添加例外网站"
        alert.informativeText = "填写域名及其子域名，例如 gmail.com。多个网站用逗号分隔。"
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 24))
        field.placeholderString = "gmail.com, docs.google.com"
        alert.accessoryView = field
        alert.addButton(withTitle: "添加")
        alert.addButton(withTitle: "取消")
        alert.window.initialFirstResponder = field
        NSApp.activate(ignoringOtherApps: true)
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        let domains = RoutingSettings.parseDomains(field.stringValue)
        guard !domains.isEmpty else {
            showMessage("未添加网站", "请填写有效域名，例如 gmail.com。")
            return
        }
        saveExcludedDomains(Array(Set(RoutingSettings().excludedDomains + domains)).sorted())
    }

    @objc private func removeExcludedDomain(_ sender: NSMenuItem) {
        guard let domain = sender.representedObject as? String else { return }
        saveExcludedDomains(RoutingSettings().excludedDomains.filter { $0 != domain })
    }

    private func saveExcludedDomains(_ domains: [String]) {
        preferences.set(domains.joined(separator: ", "), forKey: "routing.excludedDomains")
        preferences.synchronize()
        updateStatus()
    }

    @objc private func changeLoginSetting(_ sender: NSMenuItem) {
        do {
            if ![.enabled, .requiresApproval].contains(SMAppService.mainApp.status) {
                try SMAppService.mainApp.register()
                if SMAppService.mainApp.status == .requiresApproval { SMAppService.openSystemSettingsLoginItems() }
            } else { try SMAppService.mainApp.unregister() }
        } catch { showMessage("登录启动设置未完成", error.localizedDescription) }
        updateStatus()
    }

    @objc private func openExtensionDirectory(_ sender: Any?) {
        guard let directory = Bundle.main.url(forResource: "ChromeExtension", withExtension: nil) else { return }
        NSWorkspace.shared.activateFileViewerSelecting([directory])
        if let chrome = NSWorkspace.shared.urlForApplication(withBundleIdentifier: chromeBundleID) {
            NSWorkspace.shared.open([URL(string: "chrome://extensions/")!], withApplicationAt: chrome,
                                    configuration: NSWorkspace.OpenConfiguration())
        }
    }

    @objc private func connectChromeExtension(_ sender: Any?) {
        let alert = NSAlert()
        alert.messageText = "安装 Chrome 扩展"
        alert.informativeText = "先打开 Mac 应用，再从菜单栏选择“Chrome 扩展 → 安装 Chrome 扩展”。在 Chrome 确认安装后，扩展会自动连接并共用菜单栏设置。\n\n商店版本尚未发布时，可在 Chrome 的扩展管理页加载本地扩展目录。开发版连接需要从扩展弹窗点击“修复连接”。\n\n连接异常时，先选择菜单栏“修复自动连接”，再在扩展中点击“重新检测”。"
        alert.addButton(withTitle: "查看安装说明")
        alert.addButton(withTitle: "好")
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            openDirectlyInChrome(ChromeExtensionConnection.guideURL)
        }
    }

    @objc private func installChromeExtension(_ sender: Any?) {
        guard NSWorkspace.shared.urlForApplication(withBundleIdentifier: chromeBundleID) != nil else {
            showMessage("需要 Google Chrome", "请先安装 Google Chrome，再从这里安装配套扩展。")
            return
        }
        do {
            try registerNativeHost()
            extensionConfigurationError = nil
            updateStatus()
            openDirectlyInChrome(ChromeExtensionConnection.storeURL)
        } catch {
            extensionConfigurationError = error.localizedDescription
            updateStatus()
            showMessage("自动连接未配置完成", error.localizedDescription)
        }
    }

    @objc private func repairChromeExtension(_ sender: Any?) {
        do {
            try registerNativeHost()
            extensionConfigurationError = nil
            lastResult = "自动连接配置已更新，请在扩展中重新检测。"
        } catch {
            extensionConfigurationError = error.localizedDescription
            showMessage("自动连接未配置完成", error.localizedDescription)
        }
        updateStatus()
    }

    @objc private func openPrivacyPolicy(_ sender: Any?) {
        openDirectlyInChrome(ChromeExtensionConnection.privacyURL)
    }

    @objc private func makeDefault(_ sender: Any?) {
        guard !isChangingDefault else { return }
        let ownID = Bundle.main.bundleIdentifier
        if preferences.dictionary(forKey: "previousHandlers") == nil {
            var previous: [String: String] = [:]
            for scheme in supportedSchemes {
                if let identifier = handlerID(for: scheme), identifier != ownID { previous[scheme] = identifier }
            }
            if !previous.isEmpty { preferences.set(previous, forKey: "previousHandlers") }
        }
        setHandlers(supportedSchemes.map { ($0, Bundle.main.bundleURL) }, message: "已设为系统默认浏览器。")
    }

    @objc private func restoreDefault(_ sender: Any?) {
        guard !isChangingDefault,
              let previous = preferences.dictionary(forKey: "previousHandlers") as? [String: String] else { return }
        var targets: [(String, URL)] = []
        for scheme in supportedSchemes {
            guard let identifier = previous[scheme],
                  let app = NSWorkspace.shared.urlForApplication(withBundleIdentifier: identifier) else {
                showMessage("无法恢复默认浏览器", "原来的浏览器已被移动或删除，请在系统设置中选择默认浏览器。")
                return
            }
            targets.append((scheme, app))
        }
        setHandlers(targets, message: "已恢复原来的默认浏览器。")
    }

    private func setHandlers(_ targets: [(String, URL)], message: String) {
        isChangingDefault = true
        updateStatus()
        setNextHandler(targets, index: 0, message: message)
    }

    private func setNextHandler(_ targets: [(String, URL)], index: Int, message: String) {
        guard index < targets.count else {
            isChangingDefault = false
            lastResult = message
            log.write("default-handler-updated")
            updateStatus()
            return
        }
        let (scheme, target) = targets[index]
        NSWorkspace.shared.setDefaultApplication(at: target, toOpenURLsWithScheme: scheme) { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error {
                    self.isChangingDefault = false
                    self.updateStatus()
                    self.showMessage("默认浏览器未设置完成", error.localizedDescription)
                } else {
                    self.setNextHandler(targets, index: index + 1, message: message)
                }
            }
        }
    }

    @objc private func openClipboard(_ sender: Any?) {
        guard let value = NSPasteboard.general.string(forType: .string),
              let url = URL(string: value.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            showMessage("没有找到链接", "请先复制一个完整的 http 或 https 链接。")
            return
        }
        enqueue(url)
    }

    @objc private func openAutomationSettings(_ sender: Any?) {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!)
    }

    @objc private func quit(_ sender: Any?) { NSApp.terminate(nil) }

    private func showMessage(_ title: String, _ message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "好")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}

struct RouterError: Error {
    let message: String
    let code: Int
}

final class Logger {
    private let destination: URL
    init() {
        let directory = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/ChromeTabRouter", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        destination = directory.appendingPathComponent("events.log")
    }
    func write(_ action: String) {
        // Only timestamps and action names are recorded. URLs are never logged.
        let line = "\(ISO8601DateFormatter().string(from: Date())) \(action)\n"
        let data = Data(line.utf8)
        if !FileManager.default.fileExists(atPath: destination.path) {
            FileManager.default.createFile(atPath: destination.path, contents: data,
                                           attributes: [.posixPermissions: 0o600])
        } else if let handle = try? FileHandle(forWritingTo: destination) {
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
