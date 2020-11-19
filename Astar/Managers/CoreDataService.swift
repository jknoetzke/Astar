//
//  CoreDataService.swift
//  
//
//  Created by Justin Knoetzke on 2020-11-17.
//

import CoreData
import MapKit

class CoreDataServices {

    
    
    func retrieveRide(rideID: Int) -> [PeripheralData]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil}
        
        var aRideArray = [PeripheralData]()
        var aRide = PeripheralData()
        var gps = CLLocationCoordinate2D()
        var gpsData = GPSData()
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ride")
        
        fetchRequest.predicate = NSPredicate(format: "ride_number = \(rideID)")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                aRide.power = data.value(forKey: "watts") as! Int
                aRide.heartRate = data.value(forKey: "heartrate") as! Int
                aRide.gps.altitude = data.value(forKey: "altitude") as! Double
                aRide.cadence = data.value(forKey: "cadence") as! Int
                aRide.lap = data.value(forKey: "lap") as! Int
                gps.latitude = data.value(forKey: "latitude") as! Double
                gps.longitude = data.value(forKey: "longitude") as! Double
                aRide.timeStamp = data.value(forKey: "timestamp") as! Date
                aRide.gps.speed = data.value(forKey: "speed") as! Double
                gpsData.location = gps
                aRide.gps = gpsData
                
                aRideArray.append(aRide)
                aRide = PeripheralData()
                gpsData = GPSData()
                gps = CLLocationCoordinate2D()
            }
        } catch {
            print("Error retrieving CoreData")
        }
        
        return aRideArray
        
    }
    
    func retrieveRideStats(rideID: Int) -> RideMetrics {
        
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
     
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CompletedRide")
        
        var completedRide = RideMetrics()
        
        fetchRequest.predicate = NSPredicate(format: "ride_number = \(rideID)")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                completedRide.avgWatts = data.value(forKey: "average_watts") as? Int16
                completedRide.calories = data.value(forKey: "calories") as? Int16
                completedRide.distance = data.value(forKey: "distance") as? Int16
                completedRide.ride_time = data.value(forKey: "ride_time") as? Double
                completedRide.map_uuid = data.value(forKey: "map_uuid") as? String
                         
            }
        } catch {
            print("Error retrieving CoreData")
        }
        
        return completedRide
        
    }
    
    func retrieveAllRideStats() -> [RideMetrics] {
        
        var rideMetricArray = [RideMetrics]()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
     
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CompletedRide")
        
        var completedRide = RideMetrics()
        
        //fetchRequest.predicate = NSPredicate()
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                completedRide.avgWatts = data.value(forKey: "average_watts") as? Int16
                completedRide.calories = data.value(forKey: "calories") as? Int16
                completedRide.distance = data.value(forKey: "distance") as? Int16
                completedRide.ride_time = data.value(forKey: "ride_time") as? Double
                completedRide.map_uuid = data.value(forKey: "map_uuid") as? String
                         
                rideMetricArray.append(completedRide)
            }
        } catch {
            print("Error retrieving CoreData")
        }
        
        return rideMetricArray
        
    }
    
}
