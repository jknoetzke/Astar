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
    var speed:Int16?
    
    var laps: [RideMetric]?
    
}


class CoreDataServices: ObservableObject {
    
    
    static let sharedCoreDataService = CoreDataServices()
    
    @Published var rideMetrics: [RideMetric]
    
    init() {
        rideMetrics = [RideMetric]()
    }
    
    func saveMetrics(ride: [PeripheralData], mapImage: UIImage, rideID: UUID) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let rideCalculator = RideCalculator()
        let tmpRideMetric = rideCalculator.calculateRideMetrics(rideArray: ride, rideID: rideID)
        
        var completedRide = CompletedRide(context: context)
        
        completedRide.calories = tmpRideMetric.calories
        completedRide.distance = tmpRideMetric.distance
        completedRide.ride_time = tmpRideMetric.rideTime
        completedRide.ride_date = Date()
        completedRide.average_watts = tmpRideMetric.avgWatts
        completedRide.map_image = mapImage.pngData()
        completedRide.ride_id = rideID
        
        if tmpRideMetric.laps != nil {
            for lap in tmpRideMetric.laps! {
                let lapObject = Laps(context: context)
                lapObject.average_hr = lap.heartRate
                lapObject.average_speed = lap.speed!
                lapObject.average_watts = lap.avgWatts
                lapObject.distance = lap.distance
                lapObject.elevation = lap.elevation
                lapObject.lap_time = lap.rideTime
                completedRide.addToLaps(lapObject)
            }
            
        }
        
        do {
            try context.save()
            completedRide = CompletedRide(context: context)
        } catch {
            print("Error saving completed ride to CoreData")
        }
        
        let rideMetric = RideMetric(rideID: rideID, avgWatts: tmpRideMetric.avgWatts, calories: tmpRideMetric.calories, distance: tmpRideMetric.distance, rideTime: tmpRideMetric.rideTime, rideDate: tmpRideMetric.rideDate, elevation: tmpRideMetric.elevation, mapImage: mapImage)
        
        rideMetrics.append(rideMetric)
        
    }
    
    
    func saveRide(tmpRideArray: [PeripheralData], rideID: UUID) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
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
            dataRide.altitude = Double(ride.gps.altitude)
            
            do {
                try context.save()
                dataRide = Ride(context: context)
                
            }catch {
                print("Error saving to CoreData")
            }
        }
    }
    
    
    func retrieveRide(rideID: UUID) -> [PeripheralData]? {
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
    
    
    func retrieveRideStats(rideID: UUID) {
        
        var completedRides = [CompletedRide]()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedContext = appDelegate!.persistentContainer.viewContext
        //let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CompletedRide")
        
        let request: NSFetchRequest<CompletedRide> = CompletedRide.fetchRequest()
        request.predicate = NSPredicate(format: "ride_id == %@", rideID as CVarArg)
        
        
        do {
            completedRides = try managedContext.fetch(request)
        } catch let error as NSError {
            print(error)
        }
        
        let aRide = completedRides.first
        
        let rideMetric = RideMetric(rideID: rideID, avgWatts: aRide!.average_watts, calories: aRide!.calories, distance: aRide!.distance, rideTime: aRide!.ride_time, rideDate: aRide!.ride_date!, elevation: aRide!.elevation)
        
        rideMetrics.append(rideMetric)
        
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
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CompletedRide")
        
        var completedRide = RideMetric()
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                completedRide.rideID    = (data.value(forKey: "ride_id") as? UUID)!
                completedRide.avgWatts  = (data.value(forKey: "average_watts") as? Int16)!
                completedRide.calories  = (data.value(forKey: "calories") as? Int16)!
                completedRide.distance  = (data.value(forKey: "distance") as? Int16)!
                completedRide.rideTime  = (data.value(forKey: "ride_time") as? Double)!
                let dataImg = (data.value(forKey: "map_image") as? Data)!
                completedRide.mapImage  = UIImage(data: dataImg)
                completedRide.rideDate  = (data.value(forKey: "ride_date") as? Date)!
                completedRide.elevation = (data.value(forKey: "elevation") as? Int16)!
                
                rideMetrics.append(completedRide)
                
            }
        } catch {
            print("Error retrieving CoreData")
        }
        
    }
    
}
