import Foundation

struct RoutingSettings {
    static let defaults: [String: Bool] = [
        "enabled": true,
        "refreshReusedTabs": true,
        "ignoreFragments": false,
        "ignoreTrackingParameters": false,
        "ignoreQueryParameters": false,
        "useIncomingURL": true,
        "searchAllWindows": true,
        "interceptBrowserLinks": true
    ]
    let values: [String: Bool]
    let excludedDomains: [String]

    init(preferences: UserDefaults = .standard) {
        var loaded = Self.defaults
        for key in loaded.keys {
            if let value = preferences.object(forKey: "routing.\(key)") as? Bool { loaded[key] = value }
        }
        self.values = loaded
        excludedDomains = Self.parseDomains(preferences.string(forKey: "routing.excludedDomains") ?? "")
    }

    subscript(_ key: String) -> Bool { values[key] ?? false }

    var json: [String: Any] {
        var result: [String: Any] = values
        result["excludedDomains"] = excludedDomains
        return result
    }

    static func parseDomains(_ text: String) -> [String] {
        let separators = CharacterSet(charactersIn: ",，;；\n\r ")
        return Array(Set(text.components(separatedBy: separators).compactMap { value -> String? in
            var domain = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if domain.contains("://") { domain = URL(string: domain)?.host ?? "" }
            if domain.hasPrefix("*.") { domain.removeFirst(2) }
            domain = domain.trimmingCharacters(in: CharacterSet(charactersIn: "."))
            guard !domain.isEmpty, !domain.contains("/"), !domain.contains(":") else { return nil }
            return domain
        })).sorted()
    }

    func excludes(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }
        return excludedDomains.contains { host == $0 || host.hasSuffix("." + $0) }
    }

    func normalized(_ url: URL) -> String {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url.absoluteString }
        components.scheme = components.scheme?.lowercased()
        components.host = components.host?.lowercased()
        if components.path.isEmpty { components.path = "/" }
        if (components.scheme == "http" && components.port == 80) ||
            (components.scheme == "https" && components.port == 443) { components.port = nil }
        if self["ignoreFragments"] { components.fragment = nil }
        if self["ignoreQueryParameters"] {
            components.percentEncodedQuery = nil
        } else if self["ignoreTrackingParameters"], let query = components.percentEncodedQuery {
            let trackingNames: Set<String> = ["gclid", "dclid", "fbclid", "msclkid", "mc_cid", "mc_eid"]
            let remaining = query.components(separatedBy: "&").filter { item in
                let key = String(item.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false).first ?? "")
                    .removingPercentEncoding?.lowercased() ?? ""
                return !key.hasPrefix("utm_") && !trackingNames.contains(key)
            }
            components.percentEncodedQuery = remaining.isEmpty ? nil : remaining.joined(separator: "&")
        }
        return components.string ?? url.absoluteString
    }
}
