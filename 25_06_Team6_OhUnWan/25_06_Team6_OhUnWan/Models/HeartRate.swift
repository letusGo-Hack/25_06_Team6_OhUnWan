/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A model representing a heart rate measurement.
*/

import Foundation

struct HeartRate: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
