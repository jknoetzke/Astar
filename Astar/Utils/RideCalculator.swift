//
//  RideCalculator.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-17.
//

import Foundation


class RideCalculator {

    func calculateRideMetrics(rideArray: [PeripheralData], rideID: UUID) -> RideMetric {
       
        var counter = 0.0
        var totalWatts = 0.0
        let rideTime = rideArray.last?.timeStamp.timeIntervalSince(rideArray.first!.timeStamp)
        var currentLap = 0
        var distance = 0.0
        
        var lapArray = [RideMetric]()
        
        //Lap vars
        var lapCounter = 1.0
        var lapAverageWatts = 0
        var lapElevation = 0.0
        var lapDistance = 0.0
        var lapRideTime = (rideArray.first?.timeStamp)!
        var lapHeartRate = 0.0
        var lapSpeed = 0.0
        
        for ride in rideArray {
            
            
            if ride.gps.distance.value != 0 {
                distance = ride.gps.distance.value
            }
            
            totalWatts += Double(ride.power)
            lapAverageWatts += ride.power
            
            lapHeartRate += Double(ride.heartRate)
            lapSpeed += ride.gps.speed

            if currentLap != ride.lap {
                //Calculate lap data
                
                let tmpLapTime = ride.timeStamp.timeIntervalSince(lapRideTime)
                let avgWatts = Double(lapAverageWatts) / lapCounter
                let cal1 = avgWatts * tmpLapTime / 3600
                let cal2 = cal1 * 3.60
                
                var iWatts = Int(avgWatts)

                if iWatts < UInt16.min || iWatts > UInt16.max {
                    iWatts = 0
                }
                
                let avgHeartRate = lapHeartRate / lapCounter
                var iHeartRate = Int(avgHeartRate)
                
                if iHeartRate < UInt16.min || iHeartRate > UInt16.max {
                    iHeartRate = 0
                }
                
                var iSpeed = Int(lapSpeed / lapCounter)
                
                if iSpeed < UInt16.min || iHeartRate > UInt16.max {
                    iSpeed = 0
                }
                
                let rideMetric = RideMetric(rideID: rideID, avgWatts: Int16(iWatts), calories: Int16(cal2), distance: Int16(distance - lapDistance) / 1000, rideTime: ride.timeStamp.timeIntervalSince(lapRideTime), elevation: Int16(ride.elevationGained - lapElevation), heartRate: Int16(iHeartRate), speed: Int16(iSpeed), lapNumber: Int16(ride.lap))
                
                
                lapArray.append(rideMetric)
                
                lapDistance = distance
                currentLap = ride.lap
                lapRideTime = ride.timeStamp
                lapCounter = 0
                lapSpeed = 0
                lapHeartRate = 0
                lapAverageWatts = 0
                lapElevation = ride.elevationGained
                
            }
            counter += 1
            lapCounter += 1

            
        }
        
        let avgWatts = totalWatts / counter
        
        let cal1 = avgWatts * rideTime! / 3600
        let cal2 = cal1 * 3.60
        
        var rideMetric = RideMetric(avgWatts: Int16(avgWatts), calories: Int16(cal2), distance: Int16( distance / 1000.0 ), rideTime: rideTime!, rideDate: Date(), elevation: Int16(rideArray.last!.elevationGained))
        
        rideMetric.laps = lapArray
        
        return rideMetric
    }

}
    
    
