import HealthKit
import SwiftUI

@Observable
final class ProgressManager {
    
    var bodyFatData: [WeightEntry] = []
    var bodyWeightData: [WeightEntry] = []
    
    var monthBodyFatData: [WeightEntry] {
        bodyFatData.filter({ calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) })
    }
    
    var monthBodyWeightData: [WeightEntry] {
        bodyWeightData.filter({ calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) })
    }
    
    @ObservationIgnored private let calendar = Calendar.current
    @ObservationIgnored private let healthStore = HKHealthStore()
    @ObservationIgnored @AppStorage("useLBs") private var useLBs = true

    init() {
        RequestAuthorization()
    }

    private func RequestAuthorization() {
        let weight = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let bodyfat = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!
        
        let healthSet: Set = [weight, bodyfat]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthSet)
                Task {
                    try? await FetchBodyFatData()
                }
                Task {
                    try? await FetchBodyWeightData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func FetchBodyWeightData() async throws {
        async let weightData = fetchSamplesAsync(for: .bodyMass, unit: .gramUnit(with: .kilo))
        bodyWeightData = try await weightData.map {
            let converted = $0.value * (useLBs ? 2.20462 : 1)
            let rounded = round(converted * 10) / 10
            return WeightEntry(index: 0, value: rounded, date: $0.date)
        }
    }
    
    func FetchBodyFatData() async throws {
        async let bodyFatData = fetchSamplesAsync(for: .bodyFatPercentage, unit: .percent())
        self.bodyFatData = try await bodyFatData.map { WeightEntry(index: 0, value: $0.value * 100, date: $0.date) }
    }

    private func fetchSamplesAsync(for identifier: HKQuantityTypeIdentifier,unit: HKUnit) async throws -> [(date: Date, value: Double)] {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else {
            return []
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [
                    NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
                ]
            ) { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let samples = results as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }

                let allData = samples.map {
                    (date: $0.startDate, value: $0.quantity.doubleValue(for: unit))
                }

                continuation.resume(returning: allData)
            }

            healthStore.execute(query)
        }
    }

}
