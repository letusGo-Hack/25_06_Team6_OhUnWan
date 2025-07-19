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
    @State var healthStore = HealthStore()

    @State var triggerMedicationsAuthorization: Bool = false
    @State var healthDataAuthorized: Bool?
    @State private var selectedTabKind: TabKind = .medication

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTabKind) {
                Tab(.medicationViewDisplayTitle, systemImage: "calendar.day.timeline.leading", value: TabKind.medication) {
                    NavigationStack {
                        HealthKitAuthorizationGatedView(authorized: $healthDataAuthorized) {
                            MedicationListView()
                                .navigationTitle(.medicationViewDisplayTitle)
                        }
                    }
                }
                Tab(.activityViewDisplayTitle, systemImage: "figure.run", value: TabKind.activity) {
                    NavigationStack {
                        HealthKitAuthorizationGatedView(authorized: $healthDataAuthorized) {
                            ActivityView()
                        }
                    }
                }
            }
            .onAppear {
                triggerMedicationsAuthorization.toggle()
            }
            .healthDataAccessRequest(
                store: healthStore.store,
                objectType: .userAnnotatedMedicationType(),
                trigger: triggerMedicationsAuthorization
            ) { result in
                switch result {
                case .success:
                    healthDataAuthorized = true
                case .failure(let error):
                    print("Error when requesting HealthKit read authorizations: \(error)")
                }
            }
        }.environment(healthStore)
    }
}

private enum TabKind: Hashable {
    case medication
    case activity
}

extension LocalizedStringKey {
    static let medicationViewDisplayTitle: LocalizedStringKey = "Medication"
    static let activityViewDisplayTitle: LocalizedStringKey = "Activity"
}
