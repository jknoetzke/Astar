//
//  LapViewModel.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-30.
//

import Foundation
import UIKit


struct LapViewModel {

    private let ride: RideMetric
    
    var distance: Int16 {
        return ride.distance
    }
    
    var avgWatts: Int16 {
        return ride.avgWatts
    }
    
    var rideTime: Double {
        return ride.rideTime
    }
    
    var elevation: Int16 {
        return ride.elevation
    }
    
    init(ride: RideMetric) {
        self.ride = ride
    }
    
   
}
