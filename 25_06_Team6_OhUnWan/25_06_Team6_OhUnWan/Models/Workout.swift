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
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        var result = ""
        
        if hours > 0 {
            result += "\(hours)시간 "
        }
        if minutes > 0 {
            result += "\(minutes)분 "
        }
        if seconds > 0 || (hours == 0 && minutes == 0) {
            result += "\(seconds)초"
        }
        
        return result.trimmingCharacters(in: .whitespaces)
    }
}
