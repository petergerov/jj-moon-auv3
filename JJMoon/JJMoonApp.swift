import SwiftUI

@main
struct JJMoonApp: App {
    private let entitlement: EntitlementService
    private let hostModel: AudioUnitHostModel

    init() {
        entitlement = .shared
        hostModel = AudioUnitHostModel(entitlement: entitlement)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(hostModel: hostModel, entitlement: entitlement)
                .preferredColorScheme(.dark)
        }
    }
}
