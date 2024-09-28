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

import HealthKit
import SwiftUI
import Combine

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private var anchor: HKQueryAnchor?
    @Published var heartRate: Double = 0.0
    @Published var isAuthorized = false
    
    // Request authorization for heart rate data
    func requestAuthorization() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let readTypes: Set = [heartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success {
                    self.startHeartRateObserver()
                }
            }
        }
    }
    
    // Start the observer query for real-time updates
    private func startHeartRateObserver() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Observer query error: \(error.localizedDescription)")
                return
            }
            
            // Fetch the latest data whenever a new sample is available
            self?.fetchLatestHeartRateData()
            completionHandler()
        }
        
        healthStore.execute(query)
    }
    
    // Fetch the latest heart rate data
    func fetchLatestHeartRateData() { // Changed from private to internal
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: anchor,
            limit: 1
        ) { [weak self] query, samples, deletedObjects, newAnchor, error in
            if let error = error {
                print("Anchored query error: \(error.localizedDescription)")
                return
            }
            
            self?.anchor = newAnchor
            self?.handleHeartRateSamples(samples as? [HKQuantitySample] ?? [])
        }
        
        healthStore.execute(query)
    }
    
    // Handle the fetched heart rate samples
    private func handleHeartRateSamples(_ samples: [HKQuantitySample]) {
        guard let sample = samples.first else { return }
        DispatchQueue.main.async {
            self.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            print("Heart Rate read at: \(Date())") // Logs the current date and time

        }
        
        
        

    }
}
