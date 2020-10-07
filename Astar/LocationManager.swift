//
//  LocationManager.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-09-22.
//

import Foundation
import CoreLocation
import TcxDataProtocol


class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    var locationList: [CLLocation] = []
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var speed = 0.0;
    var altitude = 0.0
    var currentPosition: CLLocationCoordinate2D?
    
    var gpsDelegate: GPSDelegate?

    
    func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 3
        locationManager.startUpdatingLocation()
    }
   
    override init() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentPosition = manager.location?.coordinate

        
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else {
                continue
            }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                speed = newLocation.speed
            }
            altitude = newLocation.altitude
        }
        
        let gpsData = GPSData()
        gpsData.altitude = altitude
        gpsData.speed = speed
        gpsData.distance = distance
        gpsData.location = currentPosition
        gpsData.timeStamp = Date()
        updateGPS(gps: gpsData)
    }
    
    func updateGPS(gps: GPSData) {
        gpsDelegate?.didNewGPSData(self, gps: gps)
    }
}
