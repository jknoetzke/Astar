//
//  TCXHandler.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-02.
//

import Foundation
import TcxDataProtocol


class TCXHandler {
    
    func toPosition(location: Location) -> Position {
        return Position(latitudeDegrees: location.latitude, longitudeDegrees: location.longitude)
    }
    /*
    func generateExtensionArray(ride: PeripheralData) -> [Extension] {
        
        let extensionArray: [Extension]
        extensionArray.append(Extension(activityTrackpointExtension: ActivityTrackpointExtension(speed: ride.speed, runCadence: UInt8(ride.cadence), watts: UInt16(ride.power), cadenceSensor: nil), activityLapExtension: nil, activityGoals: nil))
        
        // Extension(activityTrackpointExtension: <#T##ActivityTrackpointExtension?#>, activityLapExtension: <#T##ActivityLapExtension?#>, activityGoals: <#T##ActivityGoals?#>)
        
        return extensionArray
        
        
        //ActivityTrackpointExtension(speed: <#T##Double?#>, runCadence: <#T##UInt8?#>, watts: <#T##UInt16?#>, cadenceSensor: <#T##CadenceSensorType?#>
    }
    
    
    func encodeTCX(rideArray: [PeripheralData]) {
        
        let build = Build(version: Version(major: 0, minor: 1, buildMajor: 0, buildMinor: 0), time: nil, builder: nil, type: .alpha)
        let author = Author(name: "TcxDataProtocol", build: build, language: nil, partNumber: "11-22-33")
        
        let lap = ActivityLap(startTime: Date(), totalTime: 45.0, distance: 12.0, maximumSpeed: nil, calories: 120, averageHeartRate: nil, maximumHeartRate: nil, intensity: .active, cadence: nil, triggerMethod: .manual, track: nil, notes: nil, extensions: nil)
        
        let activity = Activity(sport: .biking, identification: Date(), lap: [lap], notes: nil, training: nil, creator: nil)
        
        for rideRow in rideArray {
            
            let trackPoint = Trackpoint(time: rideRow.instantTimestamp, position: toPosition(location: rideRow.location), altitude: rideRow.altitude, distance: rideRow.distance, heartRate: rideRow.heartRate, cadence: rideRow.cadence, sensorState: nil, extensions: E, activityLapExtension: nil, activityGoals: nil))
            let track = Track(trackPoint: <#T##[Trackpoint]?#>)
            let activities = ActivityList(activities: [activity], multiSportSession: nil)
            
        }
        
        let database = TrainingCenterDatabase(activities: <#T##ActivityList?#>, courses: <#T##CourseList?#>, author: <#T##Author?#>)
        
        let TCXFile = TcxFile(database: database)
        
        let encodedData = try? TCXFile.encode(prettyPrinted: true)
        
        if let encodedData = encodedData {
            let xml = String(bytes: encodedData, encoding: .utf8)
          print(xml!)
        }
    }
    */
    func decodeTCX() {
        
        let filePath = Bundle.main.path(forResource: "TestFile", ofType: "tcx")
        let tcxUrl = NSURL.fileURL(withPath: filePath!)
        
        do {
            let string = try String.init(contentsOf: tcxUrl)
            print("read: " + string)
        } catch {
            print(error)
        }
        
        //let tcxUrl = URL(fileURLWithPath: "TestFile" + ".tcx")
        
        let tcxData = try? Data(contentsOf: tcxUrl)

        if let tcxData = tcxData {
            let tcxFile = try? TcxFile.decode(from: tcxData)
            print(tcxFile)
        }
    }
    
}
