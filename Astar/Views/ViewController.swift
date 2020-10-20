
import UIKit
import CoreData


class ViewController: UIViewController, RideDelegate, GPSDelegate, UITabBarControllerDelegate {
    
    private var rideTimer: Timer?
    private var seconds = 0
    private var startTime: DispatchTime?
    private var timerIsPaused = true
    private var lapCounter = 0
    private var locationManager = LocationManager()
    private var deviceManager = DeviceManager()
    private var rideArray =  [PeripheralData]()
    
    private var currentRideID = 0
    
    private var container: NSPersistentContainer!
    
    @IBOutlet weak var lblWatts: UILabel!
    @IBOutlet weak var lblHeartRate: UILabel!
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblAvgWatts: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnLap: UIButton!
    @IBOutlet weak var lblLap: UILabel!
    @IBOutlet weak var lblCadence: UILabel!
    @IBOutlet weak var lblRideTime: UILabel!
    
    private var reading = PeripheralData()
    
    private var token: String?
    
    private var totalWatts = 0
    private var wattCounter = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true

        readUserPrefs()
        rideTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        locationManager.startLocationUpdates()
        
        deviceManager.rideDelegate = self
        locationManager.gpsDelegate = self
        
        self.tabBarController?.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 {
            let mapViewController = tabBarController.viewControllers![1] as! MapViewController // or whatever tab index you're trying to access
            mapViewController.locationManager = locationManager
            mapViewController.updateCurrentLocation(newLocation: locationManager.currentLocation!)
            
        }
    }
    
    func stopTimer() {
        rideTimer?.invalidate()
        rideTimer = nil
    }
    
    func didNewRideData(_ sender: DeviceManager, ride: PeripheralData) {
        reading = ride
        lblWatts.text = String(reading.power)
        lblHeartRate.text = String(reading.heartRate)
        lblCadence.text = String(reading.cadence)
        
    }
    
    func didNewGPSData(_ sender: LocationManager, gps: GPSData) {
        reading.gps = gps
        //let speed = (gps.speed * 3600) / 1000
        lblSpeed.text = String(format: "%.0f", gps.speed)
    }
    
    @IBAction func lapClicked(_ sender: Any) {
        
        lapCounter = lapCounter + 1
        lblLap.text = String(lapCounter)
        
        totalWatts = 0
        wattCounter = 0
    }
    
    @IBAction func startClicked(_ sender: Any) {
        
        deviceManager.stopScanning()
        
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
                btnStart.setBackgroundImage(stopImage, for: .normal)
            }
            btnStart.setTitle("Stop", for: .normal)
            timerIsPaused = false
            
        } else {
            btnLap.isEnabled = false
            if #available(iOS 13, *) {
                let startImage = UIImage(systemName: "play")
                btnStart.setImage(startImage, for: .normal)
                
                btnStart.setBackgroundImage(startImage, for: .normal)
            }
            btnStart.setTitle("Start", for: .normal)
            timerIsPaused = true
            
            //Prompt user to save or not
            let alert = UIAlertController(title: "Save and Upload Ride ?", message: "Saving will save this ride to your iPhone and upload to the sites you have configured.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
                self.saveRide()
            }))
            alert.addAction(UIAlertAction(title: "Don't save", style: .cancel, handler: { action in
                print("Clicked Cancel")
            }))
            
            lapCounter = 0
            lblLap.text = "0"
            self.present(alert, animated: true)
            
        }
    }
    
    @objc func runTimedCode() {
        
        let end = DispatchTime.now()
        
       // lblWatts.text = String(reading.power)
       // lblHeartRate.text = String(reading.heartRate)
       // lblSpeed.text = String(format: "%.0f", locationManager.speed)
       // lblCadence.text = String(reading.cadence)
        
        
        if timerIsPaused == false {
            totalWatts = totalWatts + reading.power
            wattCounter = wattCounter + 1
            let averageWatts = totalWatts / wattCounter
            lblAvgWatts.text = String(averageWatts)
        
            if let tmpStartTime = startTime {
  //              let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let nanoTime = end.uptimeNanoseconds - tmpStartTime.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                let timeInterval = Double(nanoTime) / 1_000_000_000
                
                let hours = Int(timeInterval) / 3600
                let minutes = Int(timeInterval) / 60 % 60
                let seconds = Int(timeInterval) % 60
                lblRideTime.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
                
/*
                for location in locationManager.locationList {
                    let locationObject = Location(context: context)
                    locationObject.timestamp = location.timestamp
                    locationObject.latitude = location.coordinate.latitude
                    locationObject.longitude = location.coordinate.longitude
                    reading.gps.currentLocation
                    
                }
*/
                if reading.gps.location == nil { //Don't add if we haven't gotten a location yet
                    reading.gps.location = locationManager.currentPosition
                }
                reading.lap = lapCounter
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
        let dataRide = Ride(context: context)
        
        for ride in rideArray {
            
            dataRide.cadence = Int16(ride.cadence)
            dataRide.watts = Int16(ride.power)
            dataRide.distance = ride.gps.distance.value
            let location:Location = Location(context: context)
            location.latitude = ride.gps.location!.latitude
            location.longitude = ride.gps.location!.longitude
            location.timestamp = ride.gps.timeStamp
            dataRide.addToLocations(location)
            dataRide.speed = Double(ride.gps.speed)
            dataRide.heartrate = Int16(ride.heartRate)
            dataRide.timestamp =  ride.instantTimestamp
            dataRide.ride_number = Int16(currentRideID + 1)
            dataRide.altitude = Double(ride.gps.altitude)
            dataRide.ride_number = Int16(currentRideID)
        }
        currentRideID = currentRideID + 1
        saveUserPrefs()
        
        
        do {
            try context.save()
        }catch {
            
        }
        
        let tcxHandler = TCXHandler()
        let xml = tcxHandler.encodeTCX(rideArray: rideArray)
        let cyclingAnalytics = CyclingAnalyticsManager()
        
        if token == nil {
            cyclingAnalytics.auth() { (CyclingAnalyticsData) in
                //guard case self.token = CyclingAnalyticsData.access_token else { fatalError() }
                self.token = CyclingAnalyticsData.access_token
                DispatchQueue.main.async{
                    cyclingAnalytics.uploadRide(xml: xml, accessToken: self.token!)
                }
            }
        } else {
            cyclingAnalytics.uploadRide(xml: xml, accessToken: self.token!)
        }
    }
}

extension NSLayoutConstraint {
    
    override public var description: String {
        let id = identifier ?? ""
        return "Bug ! id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
