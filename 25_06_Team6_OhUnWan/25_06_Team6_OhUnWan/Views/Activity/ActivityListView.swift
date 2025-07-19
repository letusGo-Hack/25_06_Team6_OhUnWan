//
//  ActivityListView.swift
//  25_06_Team6_OhUnWan
//
//  Created by 문주성 on 7/19/25.
//

import SwiftUI
import FoundationModels

struct ActivityListView: View {
    // AI 분석을 위한 상태 변수 추가 (UI용)
    @Environment(HealthStore.self) var healthStore
    @State private var foundationModelResponse: String = ""
    @State private var isLoadingAI: Bool = false
    @State var foundationModelsService = FoundationModelsService {
        "You are personal trainer. give me an harsh advice!"
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // 활동 현황 보기 버튼
                NavigationLink(destination: ActivityView()) {
                    HStack {
                        Spacer()
                        Image(systemName: "figure.run")
                        Text("활동 현황 보기")
                        Spacer()
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.bottom)
                
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
            }
            .padding()
        }
        .navigationTitle(.activityViewDisplayTitle)
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
