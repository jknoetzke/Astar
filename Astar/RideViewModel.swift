//
//  PostViewModel.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-19.
//

import Foundation

struct RideViewModel {
    private let ride: RideMetrics
    
    var filePath: String {
        return ride.mapUUID ?? ""
    }
    
    var distance: Int16 {
        return ride.distance!
    }
    
    var avgWatts: Int16 {
        return ride.avgWatts!
    }
    
    var rideTime: Double {
        return ride.rideTime!
    }
    
    var rideDate: Date {
        return ride.rideDate ?? Date()
    }
    
    var elevation: Int16 {
        return Int16(ride.elevation!)
    }
    
    init(ride: RideMetrics) {
        self.ride = ride
    }
    
   
}
