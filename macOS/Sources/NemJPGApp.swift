import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct NemJPGApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var converter = ImageConverter()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(converter)
                .frame(minWidth: 600, minHeight: 500)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 700, height: 580)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }

        Settings {
            SettingsView()
                .environmentObject(converter)
        }
    }
}
