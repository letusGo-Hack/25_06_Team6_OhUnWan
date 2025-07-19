/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A model representing a workout.
*/

import Foundation

struct Workout: Identifiable {
    let id = UUID()
    let activityName: String
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let caloriesBurned: Double?

    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}
