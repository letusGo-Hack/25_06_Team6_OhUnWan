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
    let averageHeartRate: Double?

    var formattedDuration: String {
        let hours = Int(duration) / 3600      // 시간 계산
        let minutes = Int(duration) % 3600 / 60  // 분 계산  
        let seconds = Int(duration) % 60      // 초 계산

        if hours > 0 {
            return "\(hours)시간 \(minutes)분 \(seconds)초"
        } else if minutes > 0 {
            return "\(minutes)분 \(seconds)초"
        } else if seconds > 0 {
            return "\(seconds)초"
        } else {
            return "0초"
        }
    }
}
