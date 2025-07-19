/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A data source for providing user-authorized `HKMedicationConcepts`.
*/

import Foundation
import SwiftUI
import HealthKit

extension HKUserAnnotatedMedication {
    /// Map a list of active medication concepts.
    var activeAnnotatedMedicationConcept: AnnotatedMedicationConcept {
        var name = medication.displayText
        if let nickname, !nickname.isEmpty {
            name = nickname
        }

        return AnnotatedMedicationConcept(conceptIdentifier: medication.identifier,
                                          name: name,
                                          relatedCodings: medication.relatedCodings,
                                          isArchived: false)
    }
}

/// A class that provides access to the list of active and archived user-authorized medication concepts.
@Observable @MainActor class MedicationProvider {
    var activeMedicationConcepts: [AnnotatedMedicationConcept] = []
    var takenTodayMedicationConcepts: [AnnotatedMedicationConcept] = []
    var toTakeTodayMedicationConcepts: [AnnotatedMedicationConcept] = []

    init(store: HKHealthStore) {
        Task {
            await loadData(from: store)
        }
    }

    /// Performs a query to HealthKit to retrieve the list of active and archived medication concepts.
    func loadData(from store: HKHealthStore) async {
        do {
            /// Performs a query to HealthKit to retrieve the list of active and archived medication concepts.
            let annotatedMedicationConcepts = try await fetchMedications(from: store)
            activeMedicationConcepts = annotatedMedicationConcepts.filter { !$0.isArchived }.map { $0.activeAnnotatedMedicationConcept }

            takenTodayMedicationConcepts.removeAll()
            toTakeTodayMedicationConcepts.removeAll()

            for concept in activeMedicationConcepts {
                let taken = await checkIfTakenToday(
                    medicationIdentifier: concept.conceptIdentifier,
                    from: store
                )
                if taken {
                    takenTodayMedicationConcepts.append(concept)
                } else {
                    toTakeTodayMedicationConcepts.append(concept)
                }
            }
        } catch {
            print("Unable to retrieve any user-annotated medications \(error)")
        }
    }

    private func checkIfTakenToday(
        medicationIdentifier: HKHealthConceptIdentifier,
        from store: HKHealthStore
    ) async -> Bool {
        let medicationPredicate = HKQuery.predicateForMedicationDoseEvent(medicationConceptIdentifier: medicationIdentifier)

        let now = Date.now
        let startOfDay = Calendar.current.startOfDay(for: now)
        let loggedTodayPredicate = HKQuery.predicateForSamples(withStart: startOfDay, end: nil, options: [])
        let takenPredicate = HKQuery.predicateForMedicationDoseEvent(status: .taken)
        let sortDescriptors = [SortDescriptor(\HKSample.startDate, order: .reverse)]
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [medicationPredicate, loggedTodayPredicate, takenPredicate])
        let samplePredicate = HKSamplePredicate.sample(type: .medicationDoseEventType(), predicate: predicate)
        let queryDescriptor = HKSampleQueryDescriptor(predicates: [samplePredicate], sortDescriptors: sortDescriptors, limit: 1)

        do {
            let results = try await queryDescriptor.result(for: store)
            return !results.isEmpty
        } catch {
            print("Error checking if medication was taken today: \(error)")
            return false
        }
    }

    /// Returns a list of user-authorized `HKUserAnnotatedMedication` objects.
    func fetchMedications(from store: HKHealthStore) async throws -> [HKUserAnnotatedMedication] {
        /// Initialize the new query descriptor for fetching medications.
        let queryDescriptor = HKUserAnnotatedMedicationQueryDescriptor()

        /// The results are a list of `HKUserAnnotatedMedications`.
        /// If you supply a predicate or limit, the system returns only objects that match.
        return try await queryDescriptor.result(for: store)
    }
}
