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
        var elevation = 0.0
        var previousElevation = 0.0
        var currentLap = 0
        var distance = 0.0
        
        var lapArray = [RideMetric]()
        
        //Lap vars
        var lapCounter = 0.0
        var lapAverageWatts = 0
        var lapElevation = 0.0
        var lapPreviousElevation = 0.0
        var lapDistance = 0.0
        var lapRideTime = (rideArray.first?.timeStamp)!
        var lapHeartRate = 0.0
        var lapSpeed = 0.0
        
        for ride in rideArray {
            counter += 1
            lapCounter += 1
            
            if distance != 0 {
                distance = ride.gps.distance.value
            }
            
            totalWatts += Double(ride.power)
            lapAverageWatts += ride.power
            
            lapHeartRate += Double(ride.heartRate)
            lapSpeed += ride.speed
            
            //Did we increase in elevation ?
            if ride.gps.altitude > previousElevation && previousElevation != 0 {
                let increasedElevation = ride.gps.altitude - previousElevation
                elevation += increasedElevation
            }

            if ride.gps.altitude > lapPreviousElevation && lapPreviousElevation != 0 {
                let increasedElevation = ride.gps.altitude - lapPreviousElevation
                lapElevation += increasedElevation
            }


            previousElevation = ride.gps.altitude
            lapPreviousElevation = ride.gps.altitude
            
            
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
                
                
                let rideMetric = RideMetric(rideID: rideID, avgWatts: Int16(iWatts), calories: Int16(cal2), distance: Int16(ride.gps.distance.value - lapDistance) / 1000, rideTime: ride.timeStamp.timeIntervalSince(lapRideTime), elevation: Int16(lapElevation), heartRate: Int16(iHeartRate), speed: Int16(iSpeed), lapNumber: Int16(ride.lap))
                
                
                lapArray.append(rideMetric)
                
                lapDistance = ride.gps.distance.value
                currentLap = ride.lap
                lapRideTime = ride.timeStamp
                lapCounter = 0
                lapPreviousElevation = 0
                lapSpeed = 0
                lapHeartRate = 0
                lapAverageWatts = 0
            }
            
            
        }
        
        let avgWatts = totalWatts / counter
        
        let cal1 = avgWatts * rideTime! / 3600
        let cal2 = cal1 * 3.60
        
        var rideMetric = RideMetric(avgWatts: Int16(avgWatts), calories: Int16(cal2), distance: Int16( distance / 1000.0 ), rideTime: rideTime!, rideDate: Date(), elevation: Int16(elevation))
        
        rideMetric.laps = lapArray
        
        return rideMetric
    }

}
    
    
