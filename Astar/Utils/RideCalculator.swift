//
//  RideCalculator.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-17.
//

import Foundation
import MapKit
import CoreLocation

struct RideMetrics {
    var avgWatts: Int16?
    var calories: Int16?
    var distance: Int16?
    var rideTime: Double?
    var mapUUID: String?
    var rideDate: Date?
    
}


class RideCalculator {

    func calculateRideMetrics(rideArray: [PeripheralData]) -> RideMetrics {
       
        var counter = 0.0
        var totalWatts = 0.0
        var totalDistance = 0.0
        let rideTime = rideArray.last?.timeStamp.timeIntervalSince(rideArray.first!.timeStamp)
        
        for ride in rideArray {
            counter+=1
            totalWatts += Double(ride.power)
            totalDistance += ride.gps.distance.value
        }
        
        let avgWatts = totalWatts / counter
        
        let cal1 = avgWatts * rideTime! / 3600
        let cal2 = cal1 * 3.60
        
        
        let rideMetrics = RideMetrics(avgWatts: Int16(avgWatts), calories: Int16(cal2), distance: Int16(totalDistance/1000), rideTime: rideTime!)
        
        return rideMetrics
    }

}
    
    
