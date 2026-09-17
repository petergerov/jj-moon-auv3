import SwiftUI

@main
struct JJMoonApp: App {
    private let hostModel = AudioUnitHostModel()

    var body: some Scene {
        WindowGroup {
            ContentView(hostModel: hostModel)
                .preferredColorScheme(.dark)
        }
    }
}
