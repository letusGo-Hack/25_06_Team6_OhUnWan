//
//  FoundationModelsService.swift
//  25_06_Team6_OhUnWan
//
//  Created by 구민영 on 7/19/25.
//

import Foundation


// Foundation Models와의 통신을 담당할 클래스
class FoundationModelsService {
    
    /// 복약 데이터를 기반으로 AI 모델에 전달할 명령어를 생성하고 응답을 받아옵니다.
    /// - Parameters:
    ///   - toTakeToday: 오늘 복용할 약물 이름 목록
    ///   - takenToday: 오늘 이미 복용한 약물 이름 목록
    /// - Returns: AI 모델의 응답 문자열
    func processMedicationData(toTakeToday: [String], takenToday: [String]) async throws -> String {
        // 1. 오늘 날짜와 복약 데이터를 기반으로 명령어 문자열 생성
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let takenMeds = takenToday.joined(separator: ", ")
        let notTakenMeds = toTakeToday.joined(separator: ", ")
        
        let prompt = """
         Today is \(today).
         I have taken these medications: \(takenMeds.isEmpty ? "None" : takenMeds).
         I still need to take these medications: \(notTakenMeds.isEmpty ? "None" : notTakenMeds).
         
         Based on this information, provide a brief, encouraging, and helpful message in Korean.
         """
        
        // 2. (시뮬레이션) Foundation Models API에 `prompt`를 전달하고 응답을 기다립니다.
        print("--- Sending to Foundation Models ---")
        print(prompt)
        print("------------------------------------")
        
        // 3. (시뮬레이션) 2초 후 가짜 응답을 반환합니다.
        // TODO: 실제 Foundation Models API 호출 코드로 교체해야 합니다.
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        let simulatedResponse = "오늘도 잊지 않고 약을 챙겨 드셨네요! 남은 약도 제시간에 맞춰 복용하시고 건강한 하루 보내세요. 💪"
        
        return simulatedResponse
    }
}
