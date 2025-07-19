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
    let store = HKHealthStore()
    let medicationProvider: MedicationProvider

    init() {
        self.medicationProvider = .init(store: store)
    }

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
        let current = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: current)!

        let workoutPredicate = HKQuery.predicateForSamples(withStart: startDate, end: current, options: .strictStartDate)
        let workoutSamples = try? await HKSampleQueryDescriptor(predicates: [.workout(workoutPredicate)], sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)]).result(for: store)

        guard let workouts = workoutSamples else {
            return
        }

        var workoutData: [Workout] = []

        for workout in workouts {
            let heartRatePredicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
            let heartRateSamples = try? await HKSampleQueryDescriptor(
                predicates: [.quantitySample(type: HKQuantityType(.heartRate), predicate: heartRatePredicate)],
                sortDescriptors: []
            ).result(for: store)

            let heartRateValues = heartRateSamples?.map { $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) }
            let averageHeartRate = heartRateValues?.isEmpty == false ? (heartRateValues!.reduce(0, +) / Double(heartRateValues!.count)) : nil

            let workoutDetail = Workout(
                activityName: workout.workoutActivityType.name,
                startDate: workout.startDate,
                endDate: workout.endDate,
                duration: workout.duration,
                caloriesBurned: workout.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .kilocalorie()),
                averageHeartRate: averageHeartRate
            )
            workoutData.append(workoutDetail)
        }
        
        self.workouts = workoutData
        self.heartRateData = [] // Clear the separate heart rate data
    }
}

extension HKWorkoutActivityType {
    var name: String {
        switch self {
        case .running: return "러닝"
        case .walking: return "걷기"
        case .cycling: return "자전거"
        case .swimming: return "수영"
        case .highIntensityIntervalTraining: return "고강도 인터벌 트레이닝"
        case .yoga: return "요가"
        case .pilates: return "필라테스"
        case .barre: return "바레"
        case .coreTraining: return "코어 트레이닝"
        case .functionalStrengthTraining: return "기능성 근력 강화 운동"
        case .traditionalStrengthTraining: return "근력 강화 운동"
        case .mixedCardio: return "복합 유산소 운동"
        case .dance: return "댄스"
        case .hiking: return "하이킹"
        case .elliptical: return "일립티컬"
        case .stairClimbing: return "스탭퍼 운동"
        case .rowing: return "로잉"
        default: return "기타"
        }
    }
}
