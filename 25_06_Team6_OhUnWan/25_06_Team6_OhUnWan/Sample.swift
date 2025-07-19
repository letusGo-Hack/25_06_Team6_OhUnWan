//
//  Sample.swift
//  25_06_Team6_OhUnWan
//
//  Created by 조수환 on 7/19/25.
//

import FoundationModels
import Playgrounds

//#Playground {
//    let session = LanguageModelSession()
//
//    for try await response in session.streamResponse(to: "translate 'ㅙㄴ'") {
//        response
//    }
//
//}

import SwiftUI

struct GenerativeView: View {
    // Create a reference to the system language model.
    private let model = SystemLanguageModel.default

    var body: some View {
        switch model.availability {
        case .available:
            Circle().foregroundStyle(.green)
            // Show your intelligence UI.
        case .unavailable(.deviceNotEligible):
            Circle().foregroundStyle(.yellow)
            // Show an alternative UI.
        case .unavailable(.appleIntelligenceNotEnabled):
            Circle().foregroundStyle(.black)
            // Ask the person to turn on Apple Intelligence.
        case .unavailable(.modelNotReady):
            Circle().foregroundStyle(.red)
            // The model isn't ready because it's downloading or because of other system reasons.
        case .unavailable(let other):
            Circle().foregroundStyle(.red)
            Text("\(other)")
            // The model is unavailable for an unknown reason.
        }
    }
}

#Preview {

}
