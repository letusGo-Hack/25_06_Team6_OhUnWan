/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A shared `HKHealthStore` to use within the app.
*/

import HealthKit
import Combine

/// A reference to the shared `HKHealthStore` for views to use.
@MainActor
final class HealthStore: ObservableObject {

    static let shared: HealthStore = HealthStore()

    let healthStore = HKHealthStore()

    @Published var workouts: [Workout] = []
    @Published var heartRateData: [HeartRate] = []

    private let typesToRead: Set<HKObjectType> = [
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]

    private init() { }

    func requestActivityAuthorization() async -> Bool {
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
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
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let workoutQuery = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] (_, samples, error) in
            guard let self = self, let workouts = samples as? [HKWorkout], error == nil else {
                print("Error fetching workouts: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {

                self.workouts = workouts.map { workout in
                    Workout(activityName: workout.workoutActivityType.name,
                            startDate: workout.startDate,
                            endDate: workout.endDate,
                            duration: workout.duration,
                            caloriesBurned: workout.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .kilocalorie())
                    )
                }
            }
        }
        
        healthStore.execute(workoutQuery)

        // Fetch last 24 hours of heart rate data
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let heartRatePredicate = HKQuery.predicateForSamples(withStart: calendar.date(byAdding: .day, value: -1, to: Date()), end: Date(), options: .strictStartDate)
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: heartRatePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { [weak self] (_, samples, error) in
            guard let self = self, let heartRateSamples = samples as? [HKQuantitySample], error == nil else {
                print("Error fetching heart rate data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.heartRateData = heartRateSamples.map { sample in
                    HeartRate(date: sample.startDate, value: sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
                }
            }
        }
        
        healthStore.execute(heartRateQuery)
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
