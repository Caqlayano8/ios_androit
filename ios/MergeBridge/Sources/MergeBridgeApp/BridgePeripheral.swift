import CoreBluetooth
import Foundation

final class BridgePeripheral: NSObject, CBPeripheralManagerDelegate {
    static let serviceUUID = CBUUID(string: "4D455247-452D-4252-4944-474530303001")
    static let dataUUID = CBUUID(string: "4D455247-452D-4252-4944-474530303002")

    var onStatusChanged: ((String) -> Void)?

    private var peripheralManager: CBPeripheralManager?
    private var dataCharacteristic: CBMutableCharacteristic?
    private var lastPayload = Data()

    func start() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func update(payload: BridgePayload) {
        lastPayload = payload.encoded()

        guard let manager = peripheralManager,
              let characteristic = dataCharacteristic else {
            return
        }

        manager.updateValue(lastPayload, for: characteristic, onSubscribedCentrals: nil)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            onStatusChanged?("Ready")
            publishService()
        case .poweredOff:
            onStatusChanged?("Bluetooth off")
        case .unauthorized:
            onStatusChanged?("Not allowed")
        case .unsupported:
            onStatusChanged?("Unsupported")
        default:
            onStatusChanged?("Waiting")
        }
    }

    private func publishService() {
        let properties: CBCharacteristicProperties = [.read, .notify]
        let permissions: CBAttributePermissions = [.readable]
        let characteristic = CBMutableCharacteristic(
            type: Self.dataUUID,
            properties: properties,
            value: nil,
            permissions: permissions
        )

        let service = CBMutableService(type: Self.serviceUUID, primary: true)
        service.characteristics = [characteristic]

        dataCharacteristic = characteristic
        peripheralManager?.removeAllServices()
        peripheralManager?.add(service)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            onStatusChanged?("Service error: \(error.localizedDescription)")
            return
        }

        peripheral.startAdvertising([
            CBAdvertisementDataLocalNameKey: "MergeBridge",
            CBAdvertisementDataServiceUUIDsKey: [Self.serviceUUID]
        ])
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        if !lastPayload.isEmpty, let dataCharacteristic = dataCharacteristic {
            peripheral.updateValue(lastPayload, for: dataCharacteristic, onSubscribedCentrals: [central])
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.uuid == Self.dataUUID {
            request.value = lastPayload
            peripheral.respond(to: request, withResult: .success)
        } else {
            peripheral.respond(to: request, withResult: .attributeNotFound)
        }
    }
}
