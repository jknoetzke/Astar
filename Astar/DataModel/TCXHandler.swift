//
//  TCXHandler.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-02.
//

import Foundation
import TcxDataProtocol


class TCXHandler {
    
    struct Summary {
        var watts = 0
        var heartRate = 0
        var speed = 0
        var totalRideTime = 0.0
        var distance = 0.0
        var maxHeartRate = 0
        var maxSpeed  = 0.0
        var cadence:UInt8 = 0
    }
    
    func toPosition(lat: Double, lon: Double) -> Position {
        return Position(latitudeDegrees: lat, longitudeDegrees: lon)
    }
    
    func generateExtensionArray(ride: PeripheralData) -> [Extension] {
        
        var extensionArray: [Extension] = []
        
        let iCadence = Int(ride.cadence)
        if iCadence < UInt8.min || iCadence > UInt8.max {
            ride.cadence = 0
        }
        
        extensionArray.append(Extension(activityTrackpointExtension: ActivityTrackpointExtension(speed: ride.speed, runCadence: UInt8(ride.cadence), watts: UInt16(ride.power), cadenceSensor: nil), activityLapExtension: nil, activityGoals: nil))
        
        return extensionArray
    }
    
    func activityLaps(rideArray: [PeripheralData]) -> [ActivityLap] {
        
        var totalWatts = 0
        var totalHR = 0.0
        var totalSpeed = 0.0
        var counter = 1.0
        var distance = 0.0
        var maxSpeed = 0.0
        var cadence = 0.0
        var heartRate = 0.0
        
        var firstRecordedTime = rideArray.first?.timeStamp
        var lastRecordedTime = rideArray.last?.timeStamp
        var totalElapsedTime = lastRecordedTime?.timeIntervalSince(firstRecordedTime!)
        var totalDistance = 0.0
        var totalCadence = 0.0
        
        
        var previousLap = 0
        var activityLap = [ActivityLap]()
        var tracks: [Trackpoint] = [Trackpoint]()
        var allTracks = [Track]()
        
        for ride in rideArray {
            if previousLap == ride.lap {
                if counter == 1 {
                    firstRecordedTime = ride.timeStamp
                }
                
                if ride.speed > maxSpeed {
                    maxSpeed = ride.speed
                }
                totalWatts += ride.power
                totalHR += Double(ride.heartRate)
                totalSpeed += ride.speed
                totalDistance += ride.gps.distance.value
                totalCadence += Double(ride.cadence)
                
                let iHeartRate = Int(ride.heartRate)
                if iHeartRate < UInt8.min || iHeartRate > UInt8.max {
                    ride.heartRate = 0
                }
                
                let iCadence = Int(ride.cadence)
                if iCadence < UInt8.min || iCadence > UInt8.max {
                    ride.cadence = 0
                }
                
                let trackPoint = Trackpoint(time: ride.timeStamp, position: toPosition(lat: ride.gps.location!.latitude, lon: ride.gps.location!.longitude), altitude: Double(ride.gps.altitude), distance: ride.gps.distance.value, heartRate: HeartRateInBeatsPerMinute(heartRate: UInt8(ride.heartRate)), cadence: UInt8(ride.cadence), sensorState: nil, extensions: generateExtensionArray(ride: ride))
                
                tracks.append(trackPoint)
                
                lastRecordedTime = ride.timeStamp
                counter += 1
                
            } else { //Do some math..
                
                //We completed a lap, add it.
                allTracks.append(Track(trackPoint: tracks))
                
                //Get the averages
                distance = totalDistance / counter
                cadence = totalCadence / counter
                let heartRate = totalHR / counter
                
                var iHeartRate = Int(heartRate)
                if iHeartRate < UInt8.min || iHeartRate > UInt8.max {
                    iHeartRate = 0
                }
        
                var iCadence = Int(cadence)
                if iCadence < UInt8.min || iCadence > UInt8.max {
                    iCadence = 0
                }
                
                let heartBeatsPerMinute = HeartRateInBeatsPerMinute(heartRate: UInt8(iHeartRate))
                let lap = ActivityLap(startTime: firstRecordedTime, totalTime: Double(totalElapsedTime ?? 0), distance: distance, maximumSpeed: maxSpeed, calories: 0, averageHeartRate: heartBeatsPerMinute, maximumHeartRate: heartBeatsPerMinute, intensity: .active, cadence: UInt8(iCadence), triggerMethod: .manual, track: allTracks, notes: nil, extensions: nil)
                
                
                activityLap.append(lap)
                
                //Reset
                counter = 1
                previousLap = ride.lap
            }
        }
        
        //Finish up the last row in the array
        totalElapsedTime = lastRecordedTime?.timeIntervalSince(firstRecordedTime!)
        allTracks.append(Track(trackPoint: tracks))
        
        distance = totalDistance / counter
        cadence = totalCadence / counter
        heartRate = totalHR / counter
        
        var iHeartRate = Int(heartRate)
        if iHeartRate < UInt8.min || iHeartRate > UInt8.max {
            iHeartRate = 0
        }

        let heartBeatsPerMinute = HeartRateInBeatsPerMinute(heartRate: UInt8(iHeartRate))
        
        var iCadence = Int(cadence)
        if iCadence < UInt8.min || iCadence > UInt8.max {
            iCadence = 0
        }
        
        let lap = ActivityLap(startTime: firstRecordedTime, totalTime: Double(totalElapsedTime ?? 0), distance: distance, maximumSpeed: maxSpeed, calories: 0, averageHeartRate: heartBeatsPerMinute, maximumHeartRate: heartBeatsPerMinute, intensity: .active, cadence: UInt8(iCadence), triggerMethod: .manual, track: allTracks, notes: nil, extensions: nil)
        activityLap.append(lap)
        
        return activityLap
        
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    
    func encodeTCX(rideArray: [PeripheralData]) -> String {
        
        let build = Build(version: Version(major: 0, minor: 1, buildMajor: 0, buildMinor: 0), time: nil, builder: nil, type: .alpha)
        let author = Author(name: "Astar iPhone App", build: build, language: nil, partNumber: "11-22-33")
        let version = Version(major: 0, minor: 1, buildMajor: 0, buildMinor: 0)
        let creator = Creator(name: "Astar iPhone App", version: version, unitIdentification: nil, productIdentification: "Astar iPhone Cycle Computer")
        let activity = Activity(sport: .biking, identification: Date(), lap: activityLaps(rideArray: rideArray), notes: nil, training: nil, creator: creator)
        let activities = ActivityList(activities: [activity], multiSportSession: nil)
        let database = TrainingCenterDatabase(activities: activities, courses: nil, author: author)

        let TCXFile = TcxFile(database: database)
        let encodedData = try? TCXFile.encode(prettyPrinted: true)
        
        if let encodedData = encodedData {
            if let xml = String(bytes: encodedData, encoding: .utf8) {
                return xml
            }
        }
        
        return ""
    }
    
    
    func testEncode() -> String {
        let build = Build(version: Version(major: 0, minor: 1, buildMajor: 0, buildMinor: 0), time: nil, builder: nil, type: .alpha)
        let author = Author(name: "TcxDataProtocol", build: build, language: nil, partNumber: "11-22-33")
        
        let activityTrackpointExtension = ActivityTrackpointExtension(speed: 23.4, runCadence: 68, watts: 232, cadenceSensor: nil)
        
        let ext = Extension(activityTrackpointExtension: activityTrackpointExtension, activityLapExtension: nil, activityGoals: nil)
        
        let heartRateBPM = HeartRateInBeatsPerMinute(heartRate: 132)
        
        let position = Position(latitudeDegrees: 45.50245335325599, longitudeDegrees: -73.52809125557542)
        
        let trackPoint = Trackpoint(time: Date(), position: position, altitude: 232, distance: 33, heartRate: heartRateBPM, cadence: 91, sensorState: nil, extensions: [ext])
        
        let track = Track(trackPoint: [trackPoint])
        
        let lap = ActivityLap(startTime: Date(), totalTime: 45.0, distance: 12.0, maximumSpeed: nil, calories: 120, averageHeartRate: nil, maximumHeartRate: nil, intensity: .active, cadence: nil, triggerMethod: .manual, track: [track], notes: nil, extensions: nil)
        
        var lapArray = [ActivityLap]()
        let lap1 = ActivityLap(startTime: Date(), totalTime: 50.0, distance: 21.0, maximumSpeed: nil, calories: 100, averageHeartRate: nil, maximumHeartRate: nil, intensity: .active, cadence: nil, triggerMethod: .manual, track: nil, notes: nil, extensions: nil)
        let lap2 = ActivityLap(startTime: Date(), totalTime: 23.0, distance: 11.0, maximumSpeed: nil, calories: 200, averageHeartRate: nil, maximumHeartRate: nil, intensity: .active, cadence: nil, triggerMethod: .manual, track: nil, notes: nil, extensions: nil)
        let lap3 = ActivityLap(startTime: Date(), totalTime: 28.0, distance: 34.0, maximumSpeed: nil, calories: 140, averageHeartRate: nil, maximumHeartRate: nil, intensity: .active, cadence: nil, triggerMethod: .manual, track: nil, notes: nil, extensions: nil)
        
        lapArray.append(lap)
        lapArray.append(lap1)
        lapArray.append(lap2)
        lapArray.append(lap3)
        
        
        let activity = Activity(sport: .biking, identification: Date(), lap: lapArray, notes: nil, training: nil, creator: nil)
        
        let activities = ActivityList(activities: [activity], multiSportSession: nil)
        
        let database = TrainingCenterDatabase(activities: activities, courses: nil, author: author)
        
        let TCXFile = TcxFile(database: database)
        
        let encodedData = try? TCXFile.encode(prettyPrinted: true)
        
        if let encodedData = encodedData {
            let xml = String(bytes: encodedData, encoding: .utf8)
            print(xml!)
            return xml!
        }
       return ""
    }
 
    
}
