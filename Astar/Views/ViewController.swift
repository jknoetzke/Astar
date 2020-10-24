
import UIKit
import CoreData
import UserNotifications


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
    
    let child = SpinnerViewController()
    
    private var reading = PeripheralData()
    
    private var cyclingAnalyticsToken: String?
    
    private var totalWatts = 0
    private var wattCounter = 0
    
    //Used to determine if we've stopped pedaling or moving
    private var elapsedWattsTime = 0
    private var elapsedSpeedTime = 0
    
    
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
         
        if reading.powerEvent {
            elapsedWattsTime = 0
        }
    }
    
    func didNewGPSData(_ sender: LocationManager, gps: GPSData) {
        reading.gps = gps
       
        lblSpeed.text = String(format: "%.0f", gps.speed)
        elapsedSpeedTime = 0
    }
    
    @IBAction func lapClicked(_ sender: Any) {
        
        lapCounter = lapCounter + 1
        lblLap.text = String(lapCounter)
        
        totalWatts = 0
        wattCounter = 0

    }
    
    func startSpinnerView() {
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func stopSpinnerView()
    {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        
        // the alert view
        let alert = UIAlertController(title: "", message: "Ride Uploaded", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 3 seconds)
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
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
            alert.addAction(UIAlertAction(title: "Pause Ride", style: .cancel, handler: { action in
                print("Clicked Cancel")
            }))
            
            self.present(alert, animated: true)
            
        }
    }
    
    @objc func runTimedCode() {
        
        let end = DispatchTime.now()

        elapsedWattsTime = elapsedWattsTime + 1
        elapsedSpeedTime = elapsedSpeedTime + 1
        
        if elapsedWattsTime >= 2 {
            reading.power = 0
            reading.cadence = 0
            lblWatts.text = "0"
            lblCadence.text = "0"
        }
        
        if elapsedSpeedTime >= 2 {
            reading.speed = 0
            lblSpeed.text = "0"
        }
        
        if timerIsPaused == false {
            totalWatts = totalWatts + reading.power
            wattCounter = wattCounter + 1
            let averageWatts = totalWatts / wattCounter
            lblAvgWatts.text = String(averageWatts)
            
            if let tmpStartTime = startTime {
                let nanoTime = end.uptimeNanoseconds - tmpStartTime.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                let timeInterval = Double(nanoTime) / 1_000_000_000
                
                let hours = Int(timeInterval) / 3600
                let minutes = Int(timeInterval) / 60 % 60
                let seconds = Int(timeInterval) % 60
                lblRideTime.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
                
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
        
        /*
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
         */

        let tcxHandler = TCXHandler()
        let xml = tcxHandler.encodeTCX(rideArray: rideArray)
   
        //Cycling Analytics
        startSpinnerView()
        uploadToCyclingAnalytics(xml: xml)
        uploadToStrava(xml:xml)
        stopSpinnerView()
        
    }
    
    func uploadToStrava(xml: String) {
        let strava = StravaManager()
        strava.refresh() { (StravaData) in
            strava.storeTokens(tokenData: StravaData)
            DispatchQueue.main.async {
                print("Now going to upload...")
                strava.uploadRide(xml:xml)
            }
        }
        
    }
    
    func uploadToCyclingAnalytics(xml: String) {
        let cyclingAnalytics = CyclingAnalyticsManager()
        if cyclingAnalyticsToken == nil {
            cyclingAnalytics.auth() { (CyclingAnalyticsData) in
                self.cyclingAnalyticsToken = CyclingAnalyticsData.access_token
                DispatchQueue.main.async {
                    cyclingAnalytics.uploadRide(xml: xml, accessToken: self.cyclingAnalyticsToken!)
                }
            }
        } else {
            cyclingAnalytics.uploadRide(xml: xml, accessToken: self.cyclingAnalyticsToken!)
        }
    }
}




extension NSLayoutConstraint {
    
    override public var description: String {
        let id = identifier ?? ""
        return "Bug ! id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
