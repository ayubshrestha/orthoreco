//
//  HealthKitManager.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 16/03/2026.
//

import Foundation
import HealthKit

final class HealthKitManager {
    let healthStore = HKHealthStore()
    
    func isHealthDataAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void){
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(false, nil)
            return
        }
        
        let readTypes: Set<HKObjectType> = [stepCountType]
        
        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error  in
            DispatchQueue.main.async {
                completion(success,error)
            }
        }
    }
}
