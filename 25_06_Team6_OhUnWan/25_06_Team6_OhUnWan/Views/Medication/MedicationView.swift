/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that draws the medication tile and adds navigation to open `DoseEventView`.
*/

import HealthKit
import SwiftUI

struct MedicationView: View {

    @Environment(HealthStore.self) var healthStore
    var annotatedMedicationConcept: AnnotatedMedicationConcept
    var doseEventProvider: DoseEventProvider

    @State private var isConceptTapped = false

    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(Color.green)
                    .cornerRadius(15.0)
                    .padding(.horizontal)
                    .frame(height: 100)
                    .opacity(0.9)
                HStack {
                    Image(systemName: "pills.fill")
                        .foregroundStyle(.yellow)
                        .padding(10)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .symbolEffect(.wiggle)

                    VStack(alignment: .leading) {
                        Text(annotatedMedicationConcept.name)
                            .font(.headline)
                            .fontDesign(.rounded)

                        if let lastDose = doseEventProvider.lastDoseLogged {
                            Text("복용 시간: \(lastDose.timeLoggedDisplayString)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding()
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isConceptTapped {
                            isConceptTapped = true
                        }
                    }
                    .onEnded { _ in
                        isConceptTapped = false
                    }
            )
        }
    }
}
