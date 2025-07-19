/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A shared `HKHealthStore` to use within the app.
*/

import HealthKit
import Combine

/// A reference to the shared `HKHealthStore` for views to use.
@Observable @MainActor
final class HealthStore {
    static let shared: HealthStore = HealthStore()

    let store = HKHealthStore()

    private init() { }

    var workouts: [Workout] = []
    var heartRateData: [HeartRate] = []

    func requestActivityAuthorization() async -> Bool {
        do {
            try await store.requestAuthorization(
                toShare: [], read: [
                    HKObjectType.workoutType(),
                    HKObjectType.quantityType(forIdentifier: .heartRate)!
                ]
            )
            return true
        } catch {
            print("Error requesting HealthKit authorization: \(error.localizedDescription)")
            return false
        }
    }

    func fetchActivityData() async {
        // Fetch last 7 days of workouts
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -7, to: Date())!
        let current = Date()

        async let workoutSamples = try await HKSampleQueryDescriptor(
            predicates: [
                .workout(HKQuery.predicateForSamples(
                    withStart: calendar.date(byAdding: .day, value: -7, to: current)!,
                    end: current, options: .strictStartDate)
                )
            ],
            sortDescriptors: []
        ).result(for: store)

        async let heartRateSamples = HKSampleQueryDescriptor(
            predicates: [.quantitySample(
                type: HKQuantityType(.heartRate),
                predicate: HKQuery.predicateForSamples(
                    withStart: calendar.date(byAdding: .day, value: -1, to: current),
                    end: current, options: .strictStartDate)
            )
            ],
            sortDescriptors: [.init(\.startDate, order: .reverse)]
        ).result(for: store)

        do {
            self.workouts = try await workoutSamples.map { workout in
                Workout(activityName: workout.workoutActivityType.name,
                        startDate: workout.startDate,
                        endDate: workout.endDate,
                        duration: workout.duration,
                        caloriesBurned: workout.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .kilocalorie())
                )
            }

            self.heartRateData = try await heartRateSamples.map { sample in
                HeartRate(date: sample.startDate, value: sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
}

extension HKWorkoutActivityType {
    var name: String {
        switch self {
        case .running: return "Running"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .swimming: return "Swimming"
        case .highIntensityIntervalTraining: return "HIIT"
        case .yoga: return "Yoga"
        case .pilates: return "Pilates"
        case .barre: return "Barre"
        case .coreTraining: return "Core Training"
        case .functionalStrengthTraining: return "Functional Strength Training"
        case .traditionalStrengthTraining: return "Traditional Strength Training"
        case .mixedCardio: return "Mixed Cardio"
        case .dance: return "Dance"
        case .hiking: return "Hiking"
        case .elliptical: return "Elliptical"
        case .stairClimbing: return "Stair Climbing"
        case .rowing: return "Rowing"
        default: return "Other"
        }
    }
}
