import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationView {
            List {
                Section("Connection") {
                    StatusRow(title: "Bluetooth", value: appModel.bluetoothStatus)
                }

                Section("Permissions") {
                    StatusRow(title: "Health", value: appModel.healthStatus)
                    StatusRow(title: "Contacts", value: appModel.contactsStatus)
                }

                Section("Actions") {
                    Button("Send Health Snapshot") {
                        appModel.sendSnapshot()
                    }
                }
            }
            .navigationTitle("MergeBridge")
        }
    }
}

private struct StatusRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
