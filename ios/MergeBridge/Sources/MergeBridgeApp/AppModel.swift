import Foundation

final class AppModel: ObservableObject {
    @Published var bluetoothStatus = "Starting"
    @Published var healthStatus = "Not requested"
    @Published var contactsStatus = "Not requested"

    let healthStore = HealthStore()
    let contactsStore = ContactsStore()
    let bridgePeripheral = BridgePeripheral()

    func start() {
        bridgePeripheral.onStatusChanged = { [weak self] status in
            DispatchQueue.main.async {
                self?.bluetoothStatus = status
            }
        }

        healthStore.requestAuthorization { [weak self] result in
            DispatchQueue.main.async {
                self?.healthStatus = result
            }
        }

        contactsStore.requestAuthorization { [weak self] result in
            DispatchQueue.main.async {
                self?.contactsStatus = result
            }
        }

        bridgePeripheral.start()
    }

    func sendSnapshot() {
        healthStore.loadSnapshot { [weak self] snapshot in
            let payload = BridgePayload(
                kind: "health_snapshot",
                timestamp: Date(),
                body: snapshot
            )
            self?.bridgePeripheral.update(payload: payload)
        }
    }
}
