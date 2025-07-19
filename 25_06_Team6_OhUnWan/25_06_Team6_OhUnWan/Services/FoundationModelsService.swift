//
//  FoundationModelsService.swift
//  25_06_Team6_OhUnWan
//
//  Created by 구민영 on 7/19/25.
//

import Foundation
import FoundationModels

// Foundation Models와의 통신을 담당할 클래스
final actor FoundationModelsService {

    /// 복약 데이터를 기반으로 AI 모델에 전달할 명령어를 생성하고 응답을 받아옵니다.
    /// - Parameters:
    ///   - toTakeToday: 오늘 복용할 약물 이름 목록
    ///   - takenToday: 오늘 이미 복용한 약물 이름 목록
    /// - Returns: AI 모델의 응답 문자열
    ///

    let session: LanguageModelSession

    init(instruction: String) {
        self.session = LanguageModelSession(guardrails: .developerProvided, instructions: instruction)
    }

    init(@InstructionsBuilder instructions: () throws -> Instructions) rethrows {
        self.session = try LanguageModelSession(guardrails: .developerProvided, instructions: instructions)
    }

    func request(_ prompt: Prompt, options: GenerationOptions = .init()) async throws -> Result {
        guard !session.isResponding else {
            throw ServiceError.sessionInProgress
        }

        do {
            let response = try await session.respond(to: prompt, options: options)
            return .init(answer: response.content, temperature: options.temperature)
        } catch {
            throw error
        }
    }
}

extension FoundationModelsService {
    struct Result {
        let answer: String
        let temperature: Double?
    }

    enum ServiceError: Error {
        case sessionInProgress
    }
}
private extension LanguageModelSession.Guardrails {
    nonisolated static var developerProvided: LanguageModelSession.Guardrails {
        var guardrails = LanguageModelSession.Guardrails.default

        withUnsafeMutablePointer(to: &guardrails) { ptr in
            let rawPtr = UnsafeMutableRawPointer(ptr)
            let boolPtr = rawPtr.assumingMemoryBound(to: Bool.self)
            boolPtr.pointee = false
        }

        return guardrails
    }
}

extension Prompt {
    static func medication(toTakeToday: [String], takenToday: [String]) -> Self {
        // 1. 오늘 날짜와 복약 데이터를 기반으로 명령어 문자열 생성
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let takenMeds = takenToday.joined(separator: ", ")
        let notTakenMeds = toTakeToday.joined(separator: ", ")

        return Prompt {
            "Today is \(today)."

            "I have taken these medications: \(takenMeds.isEmpty ? "None" : takenMeds)."
            "I still need to take these medications: \(notTakenMeds.isEmpty ? "None" : notTakenMeds)."

            "Based on this information, provide a brief, encouraging, and helpful message in Korean."
        }
    }

    static func workout(_ workouts: [Workout]) -> Self {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)

        return Prompt {
            "Today is \(today)."
            if workouts.isEmpty {
                "I didn't do any workout Today"
            } else {
                for workout in workouts {
                    "I did \(workout.activityName) for \(workout.duration) seconds, with \(workout.caloriesBurned ?? 0) kcal burned\n"
                }
            }


            "Based on this information, provide a brief, encouraging, and helpful message in Korean."
        }
    }
}
