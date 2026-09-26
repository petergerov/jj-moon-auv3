import Foundation

/// Storage shared between the container app and the AUv3 extension.
///
/// Every value is written to both the App Group suite and the process's own
/// standard defaults, and read back from the group first. The standard copy
/// is the fallback for a build or device where the group container is not
/// available (unsigned simulator builds, a provisioning slip), so the app
/// still remembers state for itself even when it cannot share it.
enum SharedDefaults {
    static let appGroupID = "group.com.gerov.jjmoon"

    /// The App Group container, or nil when the entitlement isn't in effect.
    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    /// The App Group suite — only when the container really exists, since
    /// `UserDefaults(suiteName:)` happily returns a suite it can't persist.
    static var group: UserDefaults? {
        guard containerURL != nil else { return nil }
        return UserDefaults(suiteName: appGroupID)
    }

    /// The group's value if it has one, otherwise the standard one.
    static func object(forKey key: String) -> Any? {
        group?.object(forKey: key) ?? UserDefaults.standard.object(forKey: key)
    }

    static func set(_ value: Any?, forKey key: String) {
        group?.set(value, forKey: key)
        UserDefaults.standard.set(value, forKey: key)
    }
}
