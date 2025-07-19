/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays activity data from HealthKit.
*/

import SwiftUI

struct ActivityView: View {
    @StateObject private var healthStore = HealthStore.shared

    var body: some View {
        List {
            Section(header: Text("Recent Workouts (Last 7 Days)")) {
                if healthStore.workouts.isEmpty {
                    Text("No workouts found.")
                } else {
                    ForEach(healthStore.workouts) { workout in
                        VStack(alignment: .leading) {
                            Text(workout.activityName)
                                .font(.headline)
                            Text("Duration: \(workout.formattedDuration)")
                            if let calories = workout.caloriesBurned {
                                Text("Calories: \(String(format: "%.0f", calories)) kcal")
                            }
                            Text(workout.startDate, style: .date)
                        }
                    }
                }
            }

            Section(header: Text("Recent Heart Rate (Last 24 Hours)")) {
                if healthStore.heartRateData.isEmpty {
                    Text("No heart rate data found.")
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
        .onAppear {
            Task {
                await healthStore.requestActivityAuthorization()
                await healthStore.fetchActivityData()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ActivityView()
    }
}
