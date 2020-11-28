//
//  RideCalculator.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-17.
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI

//struct RideMetrics: ObservableObject {
//    var rideID: Int?
//    var avgWatts: Int16?
//    var calories: Int16?
//    var distance: Int16?
//    var rideTime: Double?
//    var mapUUID: String?
//    var rideDate: Date?
//    var elevation: Int16?
//}


class RideCalculator {

    func calculateRideMetrics(rideArray: [PeripheralData]) -> RideMetric {
       
        var counter = 0.0
        var totalWatts = 0.0
        let rideTime = rideArray.last?.timeStamp.timeIntervalSince(rideArray.first!.timeStamp)
        var elevation = 0.0
        var previousElevation = 0.0
        
        for ride in rideArray {
            counter+=1
            totalWatts += Double(ride.power)
            
            if ride.gps.altitude > previousElevation {
                elevation += ride.gps.altitude
            }
            previousElevation = ride.gps.altitude
        }
        
        let avgWatts = totalWatts / counter
        
        let cal1 = avgWatts * rideTime! / 3600
        let cal2 = cal1 * 3.60
        
        let rideMetric = RideMetric(avgWatts: Int16(avgWatts), calories: Int16(cal2), distance: Int16(rideArray.last?.gps.distance.value ?? 0), rideTime: rideTime!, rideDate: Date(), elevation: Int16(elevation))
        
        return rideMetric
    }

}
    
    
