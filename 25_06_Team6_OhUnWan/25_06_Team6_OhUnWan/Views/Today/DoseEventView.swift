/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that presents the most-recent `DoseEvent` for a selected medication.
*/

import HealthKit
import SwiftUI
import HealthKitUI

struct DoseEventView: View {

    @Environment(HealthStore.self) var healthStore
    var annotatedMedicationConcept: AnnotatedMedicationConcept

    @State private var latestDoseEvent: DoseEventModel?

    @State var doseEventProvider: DoseEventProvider

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Dose")
                    .font(.title)
                    .fontDesign(.rounded)
                    .bold()
                    .padding(.horizontal)
                if let latestDoseEvent = doseEventProvider.lastDoseLogged {
                    ZStack {
                        Rectangle()
                            .fill(Color.yellow)
                            .cornerRadius(15.0)
                            .padding(.horizontal)
                            .frame(height: 100)
                        HStack {
                            Image(systemName: "pills.circle")
                                .foregroundStyle(.orange)
                                .padding(10)
                                .font(.system(size: 24, weight: .bold, design: .monospaced))

                            Text("\(latestDoseEvent.status.description) at \(latestDoseEvent.timeLoggedDisplayString)")
                                .font(.headline)
                                .fontDesign(.rounded)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                } else {
                    Text("No Doses Logged for Today")
                        .font(.headline)
                        .padding(.leading)
                    Spacer()
                }
            }
            .navigationTitle(annotatedMedicationConcept.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
