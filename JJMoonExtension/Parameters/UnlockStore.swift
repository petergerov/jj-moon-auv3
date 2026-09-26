import Foundation

/// Cached unlock / trial state shared between the container app and AUv3 extension.
/// Trial start = first launch date (Gig Songbook pattern), stored in App Group + standard defaults.
enum UnlockStore {
    private static let effectAllowedKey = "jjmoon.effectAllowed.v1"
    private static let accessStateKey = "jjmoon.accessState.v1"
    private static let installDateKey = "jjmoon.installDate.v1"

    static var cachedEffectAllowed: Bool {
        // Before first refresh: assume trial so audio is not dry on cold start.
        SharedDefaults.object(forKey: effectAllowedKey) as? Bool ?? true
    }

    static var cachedAccessState: AccessState {
        let raw = SharedDefaults.object(forKey: accessStateKey) as? String
        return decode(raw) ?? computeAccessState(hasUnlock: false)
    }

    static var installDate: Date? {
        SharedDefaults.object(forKey: installDateKey) as? Date
    }

    /// Records first launch if missing (both app and extension call this).
    @discardableResult
    static func ensureInstallDate() -> Date {
        if let existing = installDate { return existing }
        let now = Date()
        writeInstallDate(now)
        return now
    }

    static func computeAccessState(hasUnlock: Bool) -> AccessState {
        if hasUnlock { return .unlocked }
        let start = ensureInstallDate()
        let elapsed = Date().timeIntervalSince(start)
        if elapsed < PurchaseProducts.trialDuration {
            let remaining = PurchaseProducts.trialDuration - elapsed
            let days = max(0, Int(ceil(remaining / (24 * 60 * 60))))
            return .trialActive(daysRemaining: days)
        }
        return .trialExpired
    }

    static func write(accessState: AccessState) {
        let allowed = accessState.isEffectAllowed
        SharedDefaults.set(allowed, forKey: effectAllowedKey)
        SharedDefaults.set(encode(accessState), forKey: accessStateKey)
    }

    private static func writeInstallDate(_ date: Date) {
        SharedDefaults.set(date, forKey: installDateKey)
    }

    private static func encode(_ state: AccessState) -> String {
        switch state {
        case .trialExpired: "expired"
        case .unlocked: "unlock"
        case .trialActive(let days): "trial:\(days)"
        }
    }

    private static func decode(_ raw: String?) -> AccessState? {
        guard let raw else { return nil }
        // Legacy $0-IAP state — treat as expired so user sees unlock (or still in trial via install date).
        if raw == "none" { return nil }
        if raw == "expired" { return .trialExpired }
        if raw == "unlock" { return .unlocked }
        if raw.hasPrefix("trial:"), let days = Int(raw.dropFirst(6)) {
            return .trialActive(daysRemaining: days)
        }
        return nil
    }
}
