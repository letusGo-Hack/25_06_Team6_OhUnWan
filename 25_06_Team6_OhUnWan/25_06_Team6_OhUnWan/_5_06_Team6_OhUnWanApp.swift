//
//  _5_06_Team6_OhUnWanApp.swift
//  25_06_Team6_OhUnWan
//
//  Created by 문주성 on 7/19/25.
//

import HealthKit
import SwiftUI
import HealthKitUI

@main
struct _5_06_Team6_OhUnWanApp: App {
    private let healthStore = HealthStore.shared.store

    @State var triggerMedicationsAuthorization: Bool = false
    @State var healthDataAuthorized: Bool?

    var body: some Scene {
        WindowGroup {
            TabsView(toggleHealthDataAuthorization: $triggerMedicationsAuthorization,
                     healthDataAuthorized: $healthDataAuthorized)
            .onAppear {
                triggerMedicationsAuthorization.toggle()
            }
            .healthDataAccessRequest(store: healthStore,
                                     objectType: .userAnnotatedMedicationType(),
                                     trigger: triggerMedicationsAuthorization,
                                     completion: { @Sendable result in
                Task { @MainActor in
                    switch result {
                    case .success:
                        healthDataAuthorized = true
                    case .failure(let error):
                        print("Error when requesting HealthKit read authorizations: \(error)")
                    }
                }
            })
        }
    }
}
