//
//  ActivityListView.swift
//  25_06_Team6_OhUnWan
//
//  Created by 문주성 on 7/19/25.
//

import SwiftUI
import FoundationModels

struct ActivityListView: View {
    @Environment(HealthStore.self) var healthStore
    @State private var foundationModelResponse: String = ""
    @State private var isLoadingAI: Bool = false
    @State var foundationModelsService = FoundationModelsService {
        "You are personal trainer. give me an harsh advice!"
    }

    var body: some View {
        List {
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
                    analyzeActivityWithAI()
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "sparkles")
                        Text("오늘 활동 현황 분석하기")
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
                            if let avgHeartRate = workout.averageHeartRate {
                                Text("평균 심박수: \(String(format: "%.0f", avgHeartRate)) bpm")
                            }
                            Text(workout.startDate, style: .date)
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
    
    private func analyzeActivityWithAI() {
        isLoadingAI = true
        foundationModelResponse = ""
        Task {
            do {
                let workouts = healthStore.workouts

                let response = try await foundationModelsService
                    .request(
                        .workout(workouts),
                        options: .init(temperature: .random(in: 0...2))
                    )
                foundationModelResponse = response
            } catch {
                foundationModelResponse = "오류가 발생했습니다: \(error.localizedDescription)"
            }
            isLoadingAI = false
        }
    }
}

#Preview {
    NavigationStack {
        ActivityListView()
    }
}