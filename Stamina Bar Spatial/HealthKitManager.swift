//
//  HealthKitManager.swift
//  Spatial Stamina Bar
//
//  Created by Bryce Ellis on 9/25/24.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    @Published var isHeartRateVariabilityAvailable: Bool = false
    @Published var isHeartRateAvailable: Bool = false
    @Published var latestHeartRateVariability: Double = 0
    @Published var latestHeartRate: Double = 0.0
    var query: HKQuery?

    var healthStore: HKHealthStore?

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            //healthDataAccessRequest()
        } else {
            
        }
    }
    
    
    func healthDataAccessRequest() {
        
        let readTypes: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
//            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]
        
        
        healthStore?.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if success {
                self.startHeartRateVariabilityQuery()
//                self.startHeartRateQuery()
            } else {

            }
        }
    }
    
//  MARK: HRV
    func startHeartRateVariabilityQuery() {
        guard let heartRateVariabilityType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }
        
        let query = HKAnchoredObjectQuery(type: heartRateVariabilityType,
                                          predicate: nil,
                                          anchor: nil,
                                          limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, anchor, error in
            self.updateHeartRateVariability(samples)
        }
        
        query.updateHandler = { query, samples, deletedObjects, anchor, error in
            self.updateHeartRateVariability(samples)
        }
        
        healthStore?.execute(query)
        self.query = query
    }
    
    
    private func updateHeartRateVariability(_ samples: [HKSample]? ) {
        guard let heartRateVariabilitySample = samples as? [HKQuantitySample] else { return }
        
        DispatchQueue.main.async {
            self.latestHeartRateVariability = heartRateVariabilitySample.last?.quantity.doubleValue(for: HKUnit(from: "ms")) ?? 0
            self.isHeartRateVariabilityAvailable = !heartRateVariabilitySample.isEmpty
        }
    }
}
