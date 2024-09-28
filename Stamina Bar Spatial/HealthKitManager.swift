//
//  HealthKitManager.swift
//  Stamina Bar Spatial
//
//  Created by Bryce Ellis on 9/25/24.
//


//
//  HealthKitManager.swift
//  Spatial Stamina Bar
//
//  Created by Bryce Ellis on 9/25/24.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    @Published var isHeartRateAvailable: Bool = false
    @Published var latestHeartRate: Double = 0.0
    var query: HKQuery?

    var healthStore: HKHealthStore?

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            healthDataAccessRequest()
        } else {
            
        }
    }
    
    
    func healthDataAccessRequest() {
        
        let readTypes: Set = [
//            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]
        
        
        healthStore?.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if success {
//                self.startHeartRateQuery()
            } else {

            }
        }
    }
    
    
    func startHeartRateQuery() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKAnchoredObjectQuery(type: heartRateType,
                                          predicate: nil,
                                          anchor: nil,
                                          limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, anchor, error in
            self.updateHeartRates(samples)
        }
        
        query.updateHandler = { query, samples, deletedObjects, anchor, error in
            self.updateHeartRates(samples)
        }
        
        healthStore?.execute(query)
        self.query = query
    }
    
    private func updateHeartRates(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        DispatchQueue.main.async {
            self.latestHeartRate = heartRateSamples.last?.quantity.doubleValue(for: HKUnit(from: "count/min")) ?? 0
            self.isHeartRateAvailable = !heartRateSamples.isEmpty
        }
    }
    
    
    
  
}
