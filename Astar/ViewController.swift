
import UIKit
import CoreData



class ViewController: UIViewController, RideDelegate {
    
    func didNewRideData(_ sender: DeviceManager, ride: PeripheralData) {
        reading = ride
    }
    
    private var rideTimer: Timer?
    private var seconds = 0
    private var startTime: DispatchTime?
    private var timerIsPaused = true
    private var lapCounter = 0
    private var locationManager = LocationManager()
    private var deviceManager = DeviceManager()
    private var rideArray: [PeripheralData]!
    
    private var currentRideID = 0
    
    private var container: NSPersistentContainer!
    
    @IBOutlet weak var lblWatts: UILabel!
    @IBOutlet weak var lblHeartRate: UILabel!
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblRideTime: UILabel!
    @IBOutlet weak var lblLap: UILabel!
    @IBOutlet weak var lblLapWatts: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnLap: UIButton!
    @IBOutlet weak var lblCadence: UILabel!
    
    private var reading: PeripheralData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tcxHandler = TCXHandler()
        tcxHandler.testEncode()
        
        rideTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        locationManager.startLocationUpdates()
        
        deviceManager.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
        locationManager.stopUpdatingLocation()
    }
    
    func stopTimer() {
        rideTimer?.invalidate()
        rideTimer = nil
    }
    
   
    
    @IBAction func lapClicked(_ sender: Any) {
        
        lapCounter = lapCounter + 1
        lblLap.text = String(lapCounter)
    }
    @IBAction func startClicked(_ sender: Any) {
        
        if timerIsPaused {
            startTime = DispatchTime.now()
            let hours = 0
            let minutes = 0
            let seconds = 0
            lblRideTime.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
            
            btnLap.isEnabled = true
            
            if #available(iOS 13, *) {
                let stopImage = UIImage(systemName: "stop")
                btnStart.setImage(stopImage, for: .normal)
            }
            btnStart.setTitle("Stop", for: .normal)
            timerIsPaused = false
            
        } else {
            stopTimer()
            btnLap.isEnabled = false
            if #available(iOS 13, *) {
                let startImage = UIImage(systemName: "play")
                btnStart.setImage(startImage, for: .normal)
            }
            btnStart.setTitle("Start", for: .normal)
            timerIsPaused = true
            
            //Prompt user to save or not
            let alert = UIAlertController(title: "Save and Upload Ride ?", message: "Saving will save this ride to your iPhone and upload to the sites you have configured.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
                print("Clicked Save")
            }))
            alert.addAction(UIAlertAction(title: "Don't save", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            
        }
        
        if timerIsPaused == false {
            saveRide()
        }
    }
    
    @objc func runTimedCode() {
        
        let end = DispatchTime.now()
        
        if reading == nil { return }
        
        lblWatts.text = String(reading.power)
        lblHeartRate.text = String(reading.heartRate)
        lblSpeed.text = String(locationManager.speed)
        lblCadence.text = String(reading.cadence)
        
        if timerIsPaused == false {
            if let tmpStartTime = startTime {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let nanoTime = end.uptimeNanoseconds - tmpStartTime.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                let timeInterval = Double(nanoTime) / 1_000_000_000
                
                let hours = Int(timeInterval) / 3600
                let minutes = Int(timeInterval) / 60 % 60
                let seconds = Int(timeInterval) % 60
                lblRideTime.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
                
                for location in locationManager.locationList {
                    let locationObject = Location(context: context)
                    locationObject.timestamp = location.timestamp
                    locationObject.latitude = location.coordinate.latitude
                    locationObject.longitude = location.coordinate.longitude
                    reading.location = locationObject
                    
                    reading.distance = locationManager.distance.value
                    reading.altitude = locationManager.altitude
                    
                }
                rideArray.append(reading)
            }
        }
    }
    
    private func saveUserPrefs() {
        
        let defaults = UserDefaults.standard
        defaults.set(currentRideID, forKey: "RideID")
        
    }
    
    private func readUserPrefs() {
        
        let defaults = UserDefaults.standard
        currentRideID = defaults.integer(forKey: "RideID")
        
    }
    
    private func saveRide() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if reading == nil { return }
        
        let dataRide = Ride(context: context)
        
        for ride in rideArray {
            
            dataRide.cadence = Int16(ride.cadence)
            dataRide.watts = Int16(ride.power)
            dataRide.distance = Double(ride.distance)
            dataRide.addToLocations(ride.location)
            
            dataRide.speed = ride.speed
            dataRide.heartrate = Int16(ride.heartRate)
            dataRide.timestamp =  ride.instantTimestamp
            dataRide.ride_number = Int16(currentRideID + 1)
            dataRide.altitude = ride.altitude
            
            currentRideID = currentRideID + 1
        }
        
        
        do {
            try context.save()
        }catch {
            
        }
    }
}

extension NSLayoutConstraint {
    
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
