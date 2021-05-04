//
//  CoreDataService.swift
//  
//
//  Created by Justin Knoetzke on 2020-11-17.
//

import CoreData
import MapKit


struct RideMetric {
    var rideID: UUID!
    var avgWatts:Int16 = 0
    var calories:Int16 = 0
    var distance:Int16 = 0
    var rideTime = 0.0
    var rideDate = Date()
    var elevation:Int16 = 0
    var heartRate:Int16 = 0
    var mapImage: UIImage?
    var speed:Int16 = 0
    var lapNumber:Int16 = 0
    
    var laps: [RideMetric]?
    
}


class CoreDataServices: ObservableObject {
    
    
    static let sharedCoreDataService = CoreDataServices()
    
    let persistenceController = PersistenceController.shared
    let context:NSManagedObjectContext
    
    init() {
        context = persistenceController.container.viewContext
    }
    
    
    func saveMetrics(ride: [PeripheralData], mapImage: UIImage, rideID: UUID) {
        
        let rideCalculator = RideCalculator()
        let tmpRideMetric = rideCalculator.calculateRideMetrics(rideArray: ride, rideID: rideID)
        
        let completedRide = CompletedRide(context: context)
        
        completedRide.calories = tmpRideMetric.calories
        completedRide.distance = tmpRideMetric.distance
        completedRide.ride_time = tmpRideMetric.rideTime
        completedRide.ride_date = Date()
        completedRide.average_watts = tmpRideMetric.avgWatts
        completedRide.map_image = mapImage.pngData()
        completedRide.ride_id = rideID
        completedRide.elevation = tmpRideMetric.elevation
        
        if tmpRideMetric.laps != nil {
            for lap in tmpRideMetric.laps! {
                let lapObject = Laps(context: context)
                lapObject.average_hr = lap.heartRate
                lapObject.average_speed = lap.speed
                lapObject.average_watts = lap.avgWatts
                lapObject.distance = lap.distance
                lapObject.elevation = lap.elevation
                lapObject.lap_time = lap.rideTime
                lapObject.lap_number = lap.lapNumber
                
                completedRide.addToLaps(lapObject)
            }
            
        }
        
        do {
            try context.save()
            //completedRide = CompletedRide(context: context)
        } catch {
            print("Error saving completed ride to CoreData")
        }
        
    }
    
    
    func saveRide(tmpRideArray: [PeripheralData], rideID: UUID) {
        
        var dataRide = Ride(context: context)
        
        for ride in tmpRideArray {
            
            dataRide.ride_id = rideID
            dataRide.cadence = Int16(ride.cadence)
            dataRide.watts = Int16(ride.power)
            dataRide.latitude = ride.gps.location?.latitude ?? 0.0
            dataRide.longitude = ride.gps.location?.longitude ?? 0.0
            dataRide.speed = Double(ride.gps.speed)
            dataRide.heartrate = Int16(ride.heartRate)
            dataRide.timestamp =  ride.timeStamp
            dataRide.ride_id = rideID
            dataRide.altitude = ride.elevation
            
            do {
                try context.save()
                dataRide = Ride(context: context)
                
            }catch {
                print("Error saving to CoreData")
            }
        }
    }
    
    
    func retrieveRide(rideID: UUID) -> [PeripheralData]? {
        
        var aRideArray = [PeripheralData]()
        var aRide = PeripheralData()
        var gps = CLLocationCoordinate2D()
        var gpsData = GPSData()
        
        //let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ride")
        
        fetchRequest.predicate = NSPredicate(format: "ride_id == %@", rideID as CVarArg)
        let sort = NSSortDescriptor(key: #keyPath(Ride.timestamp), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            //let result = try managedContext.fetch(fetchRequest)
            let result = try context.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                aRide.power = data.value(forKey: "watts") as! Int
                aRide.heartRate = data.value(forKey: "heartrate") as! Int
                aRide.elevation = data.value(forKey: "altitude") as! Double
                aRide.cadence = data.value(forKey: "cadence") as! Int
                aRide.lap = data.value(forKey: "lap") as! Int
                gps.latitude = data.value(forKey: "latitude") as! Double
                gps.longitude = data.value(forKey: "longitude") as! Double
                aRide.timeStamp = data.value(forKey: "timestamp") as! Date
                gpsData.speed = data.value(forKey: "speed") as! Double
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
    /*
    
    
    func retrieveRideStats(rideID: UUID) {
        
        var completedRides = [CompletedRide]()
        
        let request: NSFetchRequest<CompletedRide> = CompletedRide.fetchRequest()
        request.predicate = NSPredicate(format: "ride_id == %@", rideID as CVarArg)
        
        
        do {
            completedRides = try context.fetch(request)
        } catch let error as NSError {
            print(error)
        }
    }
    
    static func load(fileName: String) -> UIImage? {
        
        print("Filename: \(fileName)")
        
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        print("File URL: \(fileURL)")
        
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func retrieveAllRideStats() {
        
        let fetchRequest: NSFetchRequest<CompletedRide> = CompletedRide.fetchRequest()
        
        var tmpLaps = [RideMetric]()
        var completedRides = [CompletedRide]()
        
        do {
            completedRides = try context.fetch(fetchRequest)
            
            for completedRide in completedRides {
                var rideMetric = RideMetric()
                rideMetric.avgWatts = completedRide.average_watts
                rideMetric.calories = completedRide.calories
                rideMetric.distance = completedRide.distance
                rideMetric.elevation = completedRide.elevation
                let lapSet = completedRide.laps
                let set = lapSet as? Set<Laps> ?? []
                let laps = set.sorted { $0.lap_number < $1.lap_number }
                
                for lap in laps {
                    var lapMetric = RideMetric()
                    lapMetric.avgWatts = lap.average_watts
                    lapMetric.speed = lap.average_speed
                    lapMetric.distance = lap.distance
                    lapMetric.elevation = lap.elevation
                    lapMetric.heartRate = lap.average_hr
                    lapMetric.rideTime = lap.lap_time
                    lapMetric.lapNumber = lap.lap_number
                    tmpLaps.append(lapMetric)
                }
                
                let dataImg = completedRide.map_image
                rideMetric.mapImage = UIImage(data: dataImg!)
                rideMetric.rideDate = completedRide.ride_date!
                rideMetric.rideTime = completedRide.ride_time
                rideMetric.rideID = completedRide.ride_id
  
                rideMetric.laps = tmpLaps
//                rideMetrics.append(rideMetric)
                tmpLaps.removeAll()
                
            }
 } catch {
            print("Error retrieving CoreData")
        }
        
    }
 */
}
