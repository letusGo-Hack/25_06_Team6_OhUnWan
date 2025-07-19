/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays activity data from HealthKit.
*/

import SwiftUI

struct ActivityView: View {
    @Environment(HealthStore.self) var healthStore

    var body: some View {
        List {
            Section(header: Text("최근 운동 (최근 7일)")) {
                if healthStore.workouts.isEmpty {
                    Text("운동 기록이 없습니다.")
                } else {
                    ForEach(healthStore.workouts) { workout in
                        VStack(alignment: .leading) {
                            Text(workout.activityName)
                                .font(.headline)
                            Text("시간: \(workout.formattedDuration)")
                            if let calories = workout.caloriesBurned {
                                Text("칼로리: \(String(format: "%.0f", calories)) kcal")
                            }
                            Text(workout.startDate, style: .date)
                        }
                    }
                }
            }

            Section(header: Text("최근 심박수 (최근 24시간)")) {
                if healthStore.heartRateData.isEmpty {
                    Text("심박수 데이터가 없습니다.")
                } else {
                    ForEach(healthStore.heartRateData) { heartRate in
                        HStack {
                            Text("\(String(format: "%.0f", heartRate.value)) bpm")
                            Spacer()
                            Text(heartRate.date, style: .time)
                        }
                    }
                }
            }
        }
        .navigationTitle(.activityViewDisplayTitle)
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .task {
            guard await healthStore.requestActivityAuthorization() else {
                return 
            }
            await healthStore.fetchActivityData()
        }
    }
}

#Preview {
    NavigationStack {
        ActivityView()
    }
}
