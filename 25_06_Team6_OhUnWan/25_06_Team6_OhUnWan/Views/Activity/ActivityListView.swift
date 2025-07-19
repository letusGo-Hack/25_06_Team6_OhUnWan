//
//  ActivityListView.swift
//  25_06_Team6_OhUnWan
//
//  Created by 문주성 on 7/19/25.
//

import SwiftUI

struct ActivityListView: View {
    // AI 분석을 위한 상태 변수 추가 (UI용)
    @State private var foundationModelResponse: String = ""
    @State private var isLoadingAI: Bool = false
    
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
        
        // 임시로 UI만 표시하는 더미 응답
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.foundationModelResponse = "오늘의 활동 현황을 분석한 결과:\n\n• 운동 시간: 30분\n• 걸음 수: 8,500보\n• 심박수: 평균 72bpm\n\n전반적으로 적절한 활동량을 유지하고 계십니다. 규칙적인 운동을 계속하시면 건강에 도움이 될 것입니다."
            self.isLoadingAI = false
        }
    }
}

#Preview {
    NavigationStack {
        ActivityListView()
    }
}
