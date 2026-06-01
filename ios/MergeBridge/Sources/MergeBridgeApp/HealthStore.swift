import Foundation
import HealthKit

final class HealthStore {
    private let store = HKHealthStore()

    func requestAuthorization(completion: @escaping (String) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion("Unavailable")
            return
        }

        var readTypes = Set<HKObjectType>()

        if let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) {
            readTypes.insert(stepCount)
        }
        if let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) {
            readTypes.insert(heartRate)
        }
        if let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            readTypes.insert(activeEnergy)
        }
        readTypes.insert(HKObjectType.workoutType())

        store.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if let error = error {
                completion("Error: \(error.localizedDescription)")
            } else {
                completion(success ? "Allowed" : "Denied")
            }
        }
    }

    func loadSnapshot(completion: @escaping ([String: String]) -> Void) {
        var snapshot: [String: String] = [:]
        let group = DispatchGroup()

        group.enter()
        readTodaySum(.stepCount, unit: .count()) { value in
            snapshot["steps"] = value
            group.leave()
        }

        group.enter()
        readTodaySum(.activeEnergyBurned, unit: .kilocalorie()) { value in
            snapshot["active_energy_kcal"] = value
            group.leave()
        }

        group.notify(queue: .main) {
            completion(snapshot)
        }
    }

    private func readTodaySum(_ identifier: HKQuantityTypeIdentifier, unit: HKUnit, completion: @escaping (String) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            completion("0")
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            completion(String(format: "%.0f", value))
        }

        store.execute(query)
    }
}
