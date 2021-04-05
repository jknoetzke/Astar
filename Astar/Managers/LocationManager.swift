//
//  LocationManager.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-09-22.
//

import Foundation
import CoreLocation
import TcxDataProtocol
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate  {
    
    static let sharedLocationManager = LocationManager()
    
    private let locationManager = CLLocationManager()
    var locationList: [CLLocation] = []
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var speed = 0.0;
    var altitude = 0.0
    var currentPosition: CLLocationCoordinate2D?
    var currentLocation: CLLocation?
    
    var gpsDelegate: GPSDelegate?
    var locationDelegate: LocationDelegate?
    
    var coordinate2D = [CLLocation]()
    
    func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 3
        locationManager.startUpdatingLocation()
    }
    
    override init() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let gpsData = GPSData()
        
        currentPosition = manager.location?.coordinate
        
        coordinate2D.append(locations.first!)
        
        for newLocation in locations {
            
            gpsData.currentLocation = newLocation
            currentLocation = newLocation
            
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else {
                continue
            }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                
                speed = (newLocation.speed * 3600) / 1000
                gpsData.lastLocation = lastLocation
            }
            locationList.append(newLocation)
            altitude = newLocation.altitude
            
        }
        
        
        
        //gpsData.altitude = altitude
        gpsData.altitude = Double.random(in: 0...100)
        gpsData.speed = speed
        gpsData.distance = distance
        gpsData.location = currentPosition
        
        updateGPSData(gps: gpsData)
        
        if currentLocation != nil && gpsData.lastLocation != nil {
            updateNewLocationData(newLocation: gpsData.currentLocation!, oldLocation: gpsData.lastLocation!)
        }
    }
    
    
    func updateGPSData(gps: GPSData) {
        gpsDelegate?.didNewGPSData(self, gps: gps)
    }
    
    func updateNewLocationData(newLocation: CLLocation, oldLocation: CLLocation) {
        locationDelegate?.didNewLocationData(self, newLocation: newLocation, oldLocation: oldLocation)
    }
}
