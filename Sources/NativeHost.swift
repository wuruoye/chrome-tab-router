import AppKit

func runNativeHost() {
    do {
        guard let header = try readExactly(4) else { exit(0) }
        let bytes = Array(header)
        let length = Int(UInt32(bytes[0]) | UInt32(bytes[1]) << 8 | UInt32(bytes[2]) << 16 | UInt32(bytes[3]) << 24)
        guard length > 0, length <= 65536, let payload = try readExactly(length),
              let request = try JSONSerialization.jsonObject(with: payload) as? [String: Any] else {
            try sendNativeResponse(["ok": false, "error": "请求格式不正确。"])
            exit(0)
        }
        switch request["action"] as? String {
        case "settings":
            try sendNativeResponse(["ok": true, "settings": RoutingSettings().json])
        case "openSettings":
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true
            NSWorkspace.shared.open([URL(string: "chrometabrouter://settings")!], withApplicationAt: Bundle.main.bundleURL,
                                    configuration: configuration) { _, error in
                try? sendNativeResponse(["ok": error == nil])
                exit(0)
            }
            RunLoop.main.run()
        case "route":
            guard let raw = request["url"] as? String, raw.utf8.count <= 16384,
                  let url = URL(string: raw), ["http", "https"].contains(url.scheme?.lowercased() ?? ""),
                  url.host != nil else {
                try sendNativeResponse(["ok": false, "error": "只支持 http 和 https 链接。"])
                exit(0)
            }
            NSWorkspace.shared.open([url], withApplicationAt: Bundle.main.bundleURL,
                                    configuration: NSWorkspace.OpenConfiguration()) { _, error in
                try? sendNativeResponse(["ok": error == nil,
                                         "error": error == nil ? "" : "无法启动 Mac 应用。"])
                exit(0)
            }
            RunLoop.main.run()
        default:
            try sendNativeResponse(["ok": false, "error": "未知请求。"])
        }
    } catch {
        try? sendNativeResponse(["ok": false, "error": "本地连接失败。"])
    }
    exit(0)
}

private func readExactly(_ count: Int) throws -> Data? {
    var data = Data()
    while data.count < count {
        guard let part = try FileHandle.standardInput.read(upToCount: count - data.count), !part.isEmpty else { return nil }
        data.append(part)
    }
    return data
}

private func sendNativeResponse(_ response: [String: Any]) throws {
    let payload = try JSONSerialization.data(withJSONObject: response, options: [.sortedKeys])
    let length = UInt32(payload.count)
    let header = Data([UInt8(length & 0xff), UInt8((length >> 8) & 0xff),
                       UInt8((length >> 16) & 0xff), UInt8((length >> 24) & 0xff)])
    try FileHandle.standardOutput.write(contentsOf: header + payload)
}

func connectExtension(_ identifier: String) throws {
    guard identifier.range(of: "^[a-p]{32}$", options: .regularExpression) != nil else {
        throw RouterError(message: "扩展 ID 应为 Chrome 扩展页面显示的 32 位字母。", code: 0)
    }
    let directory = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/Google/Chrome/NativeMessagingHosts", isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let manifest: [String: Any] = [
        "name": "com.sigma.chrome_tab_router",
        "description": "Chrome Tab Router local link bridge",
        "path": Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/NativeHost").path,
        "type": "stdio",
        "allowed_origins": ["chrome-extension://\(identifier)/"]
    ]
    let destination = directory.appendingPathComponent("com.sigma.chrome_tab_router.json")
    try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys]).write(to: destination, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: destination.path)
    UserDefaults.standard.set(identifier, forKey: "chromeExtensionID")
    UserDefaults.standard.synchronize()
}
