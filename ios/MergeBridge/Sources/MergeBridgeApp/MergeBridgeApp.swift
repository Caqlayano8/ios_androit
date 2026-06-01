import SwiftUI

@main
struct MergeBridgeApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
                .onAppear {
                    appModel.start()
                }
        }
    }
}
