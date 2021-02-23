
import UIKit
import CoreData
import UserNotifications


class ViewController: UIViewController, RideDelegate, GPSDelegate, UITabBarControllerDelegate {

    private var rideTimer: Timer?
    private var seconds = 0
    private var startTime: DispatchTime?
    private var timerIsPaused = true
    private var lapCounter = 0
    private var locationManager = LocationManager.sharedLocationManager
    private var deviceManager = DeviceManager.deviceManagerInstance
    private var rideArray =  [PeripheralData]()
    private var stravaFlag  = false
    private var cyclingAnalyticsFlag = false

    private var currentRideID = 0
    
    private var container: NSPersistentContainer!
    
    @IBOutlet weak var lblWatts: UILabel!
    @IBOutlet weak var lblHeartRate: UILabel!
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblRideTime: UILabel!
    @IBOutlet weak var lblCadence: UILabel!
    @IBOutlet weak var lblLap: UILabel!
    @IBOutlet weak var lblAvgWatts: UILabel!

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnLap: UIButton!

    
    @IBOutlet weak var ROW1: UILabel!
    @IBOutlet weak var ROW2COL1: UILabel!
    @IBOutlet weak var ROW2COL2: UILabel!
    @IBOutlet weak var ROW3COL1: UILabel!
    @IBOutlet weak var ROW3COL2: UILabel!
    @IBOutlet weak var ROW4COL1: UILabel!
    @IBOutlet weak var ROW4COL2: UILabel!
    
    
    
    let child = SpinnerViewController()
    
    private var reading = PeripheralData()
    
    private var cyclingAnalyticsToken: String?
    
    private var totalWatts = 0
    private var wattCounter = 0
    
    //Used to determine if we've stopped pedaling or moving
    private var elapsedWattsTime = 0
    private var elapsedSpeedTime = 0
    
    //Was a periperhal added or removed ?
    var startScanning = true //Scan at startup then stop.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        readUserPrefs()
        
        locationManager.startLocationUpdates()
        
        deviceManager.rideDelegate = self
        locationManager.gpsDelegate = self
        self.tabBarController?.delegate = self
        
        let mapViewController = tabBarController!.viewControllers![2] as! MapViewController // or whatever tab index you're trying to access
        mapViewController.loadView()
        mapViewController.viewDidLoad()
        mapViewController.viewWillAppear(false)
        mapViewController.viewDidAppear(false)
    }
    
    /*
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 {
            var mapViewController = tabBarController.viewControllers![2] as! MapViewController // or whatever tab index you're trying to access
            mapViewController = mapController as! MapViewController
        }
    }
    */
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deviceManager.stopScanning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Reset view for possible new custom layout
        
        setCustomUI()
        
        
        if startScanning {
            deviceManager.startScanning(fullScan: false)
            startScanning = false
        }
    }
    
    func setCustomUI() {
        
        let customFields = ["ROW1", "ROW2COL1", "ROW2COL2", "ROW3COL1", "ROW3COL2", "ROW4COL1", "ROW4COL2"]

        for i in 0..<fields.count {
            switch(i) {
            case 0:
                if getCustomField(customField: customFields[i]) != -1 {
                    ROW1.text = fields[getCustomField(customField: customFields[i])]
                }
                break;
            case 1:
                if getCustomField(customField: customFields[i]) != -1 {
                    ROW2COL1.text = fields[getCustomField(customField: customFields[i])]
                }
                break;
            case 2:
                if getCustomField(customField: customFields[i]) != -1 {
                   ROW2COL2.text = fields[getCustomField(customField: customFields[i])]
                }
                break;
            case 3:
                if getCustomField(customField: customFields[i]) != -1 {
                    ROW3COL1.text = fields[getCustomField(customField: customFields[i])]
                }
                break;
            case 4:
                if getCustomField(customField: customFields[i]) != -1 {
                    ROW3COL2.text = fields[getCustomField(customField: customFields[i])]
                }
                break;
            case 5:
                if getCustomField(customField: customFields[i]) != -1 {
                   ROW4COL1.text = fields[getCustomField(customField: customFields[i])]
                }
                break;
            case 6:
                if getCustomField(customField: customFields[i]) != -1 {
                   ROW4COL2.text = fields[getCustomField(customField: customFields[i])]
                }
                break;
            default:
                print("Oops")
            }
            
        }
    }
    
    func stopTimer() {
        rideTimer?.invalidate()
        rideTimer = nil
    }
    
    func didNewRideData(_ sender: DeviceManager, ride: PeripheralData) {
        reading = ride
        
        if reading.hrEvent {
            lblHeartRate.text = String(reading.heartRate)
        }
        
        if reading.powerEvent {
            lblWatts.text = String(reading.power)
            lblCadence.text = String(reading.cadence)
            elapsedWattsTime = 0
            
            if timerIsPaused == false {
                totalWatts = totalWatts + reading.power
                wattCounter = wattCounter + 1
                let averageWatts = totalWatts / wattCounter
                lblAvgWatts.text = String(averageWatts)
            }
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
        let alert = UIAlertController(title: "", message: "Uploading Ride...", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 3 seconds)
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func startClicked(_ sender: Any) {
        
        if timerIsPaused {
            rideTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
            startTime = DispatchTime.now()
            let hours = 0
            let minutes = 0
            let seconds = 0
            lblRideTime.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
            let stopImage = UIImage(systemName: "stop")
            btnStart.setImage(stopImage, for: .normal)
            btnStart.setBackgroundImage(stopImage, for: .normal)
            btnStart.setTitle("Stop", for: .normal)
            timerIsPaused = false
            btnLap.isEnabled = true
            
        } else {
            
            //Prompt user to save or not
            let alert = UIAlertController(title: "Save and Upload Ride ?", message: "Saving will save this ride to your iPhone and upload to the sites you have configured.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
                print("Save Ride")
                self.saveRide(tmpRideArray: self.rideArray)
                print("Ride Saved.. Resetting")
                self.resetRide()
                print("Ride Reset")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                print("Clicked Cancel")
                self.timerIsPaused = false
            }))
            alert.addAction(UIAlertAction(title: "Discard Ride", style: .destructive, handler: { action in
                print("Discarded Ride")
                self.resetRide()
            }))

            self.present(alert, animated: true)
            
        }
    }
    
    func getCustomField(customField: String) -> Int  {
        
        let defaults = UserDefaults.standard
        
        let rc = defaults.integer(forKey: customField)
        if rc == 0 {
            if !isKeyPresentInUserDefaults(key: customField) {
                return -1
            }
        }
        return rc
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    func resetRide() {
        rideArray.removeAll()
        timerIsPaused = true
        btnLap.isEnabled = false
        rideTimer?.invalidate()
        
        let startImage = UIImage(systemName: "play")
        btnStart.setImage(startImage, for: .normal)
        btnStart.setBackgroundImage(startImage, for: .normal)
        btnStart.setTitle("Start", for: .normal)
        lblAvgWatts.text = "0"
        lblLap.text = "0"

    }
    
    @objc func runTimedCode() {
        
        let end = DispatchTime.now()
        
        elapsedWattsTime = elapsedWattsTime + 1
        elapsedSpeedTime = elapsedSpeedTime + 1
        
        if elapsedWattsTime >= 3 {
            reading.power = 0
            reading.cadence = 0
            lblWatts.text = "0"
            lblCadence.text = "0"
        }
        
        if elapsedSpeedTime >= 3 {
            reading.speed = 0
            lblSpeed.text = "0"
        }
        
        if !timerIsPaused {
            
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
                
                let tmpGPS = reading.gps
                let tmpReading = reading
                
                reading = PeripheralData()
                
                //Just in case
                reading.power = tmpReading.power
                reading.cadence = tmpReading.cadence
                reading.deviceType = DeviceType.PowerMeter
                reading.gps = tmpGPS
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
        stravaFlag = defaults.bool(forKey: "strava")
        cyclingAnalyticsFlag = defaults.bool(forKey: "cycling_analytics")
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func saveRide(tmpRideArray: [PeripheralData]) {
  
        let coreDataServices = CoreDataServices.sharedCoreDataService
        
        let rideID = UUID() //Create the unique ID for the ride
        //Save the Ride itself
        coreDataServices.saveRide(tmpRideArray: tmpRideArray, rideID: rideID)

        //Save The map
        
        let mapViewController = tabBarController!.viewControllers![2] as! MapViewController // or whatever tab index you're trying to access
        mapViewController.generateImageFromMap(ride: tmpRideArray, rideID: rideID)

        
        //Upload to Strava and Cycling Analytics
        if stravaFlag || cyclingAnalyticsFlag {
            let tcxHandler = TCXHandler()
            let xml = tcxHandler.encodeTCX(rideArray: tmpRideArray)
            startSpinnerView()
            if cyclingAnalyticsFlag {
                uploadToCyclingAnalytics(xml: xml)
            }
            if stravaFlag {
                uploadToStrava(xml:xml)
            }
            stopSpinnerView()
        }
    }
    
    func uploadToStrava(xml: String) {
        let strava = StravaManager()
        
        strava.refresh() { (StravaData) in
            strava.storeTokens(tokenData: StravaData)
            DispatchQueue.main.async {
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
