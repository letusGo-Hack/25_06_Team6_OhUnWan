/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 A view that displays active and archived user-authorized medications.
 */

import SwiftUI
import UIKit
import FoundationModels

struct MedicationListView: View {
    @Environment(HealthStore.self) var healthStore

    // AI 분석을 위한 상태 변수 추가
    @State private var foundationModelResponse: String = ""
    @State private var isLoadingAI: Bool = false
    @State var foundationModelsService = FoundationModelsService {
        "You are a phamacist. give me an useful advice for Medicine!"
    }

    var body: some View {
        let medicationProvider = healthStore.medicationProvider
        ScrollView {
            VStack(alignment: .leading) {
                Section(header: Text("To Take Today")
                    .textCase(nil)
                    .font(.title3)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .padding(4)
                ) {
                    if medicationProvider.toTakeTodayMedicationConcepts.isEmpty &&
                        medicationProvider.takenTodayMedicationConcepts.isEmpty {
                        Text("No active medications.")
                            .padding()
                    } else if medicationProvider.toTakeTodayMedicationConcepts.isEmpty {
                        Text("All medications taken for today!")
                            .padding()
                    } else {
                        ForEach(medicationProvider.toTakeTodayMedicationConcepts) { concept in
                            MedicationView(
                                annotatedMedicationConcept: concept,
                                doseEventProvider: DoseEventProvider(
                                    healthStore: healthStore.store,
                                    annotatedMedicationConcept: concept
                                )
                            )
                        }
                    }
                }
                
                Section(header: Text("Taken Today")
                    .textCase(nil)
                    .font(.title3)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .padding(4)
                ) {
                    if !medicationProvider.takenTodayMedicationConcepts.isEmpty {
                        ForEach(medicationProvider.takenTodayMedicationConcepts) { concept in
                            MedicationView(
                                annotatedMedicationConcept: concept,
                                doseEventProvider: DoseEventProvider(
                                    healthStore: healthStore.store,
                                    annotatedMedicationConcept: concept
                                )
                            )
                        }
                    }
                }
                
                // AI 건강 코칭 섹션 추가
                Section(header: Text("AI 건강 코칭")
                    .textCase(nil)
                    .font(.title3)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .padding(4)
                ) {
                    if isLoadingAI {
                        HStack {
                            ProgressView()
                            Text("AI가 분석 중입니다...")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else {
                        if !foundationModelResponse.isEmpty {
                            Text(foundationModelResponse)
                                .font(.body)
                                .foregroundColor(.blue)
                                .padding()
                        }
                    }
                    
                    Button(action: {
                        analyzeMedicationWithAI()
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "sparkles")
                            Text("오늘 복약 현황 분석하기")
                            Spacer()
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoadingAI)
                }
                
                
            }
            .padding()
            .task {
                await medicationProvider.loadData(from: healthStore.store)
            }
        }
    }
    
    private func analyzeMedicationWithAI() {
        isLoadingAI = true
        foundationModelResponse = ""
        let medicationProvider = healthStore.medicationProvider
        Task {
            do {
                let toTake = medicationProvider.toTakeTodayMedicationConcepts.map { $0.name }
                let taken = medicationProvider.takenTodayMedicationConcepts.map { $0.name }
                
                let response = try await foundationModelsService
                    .request(
                        .medication(
                            toTakeToday: toTake,
                            takenToday: taken
                        ),
                        options: .init(temperature: .random(in: 0...2))
                    )
                self.foundationModelResponse = response
            } catch {
                self.foundationModelResponse = "오류가 발생했습니다: \(error.localizedDescription)"
            }
            self.isLoadingAI = false
        }
    }
}

#Preview {
    MedicationListView()
}
