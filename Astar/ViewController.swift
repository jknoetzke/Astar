
import UIKit
import CoreData

class ViewController: UIViewController {
    private var rideTimer: Timer?
    private var clock: Timer?
    private var seconds = 0
    private var startTime: DispatchTime?
    private var timerIsPaused = true
    private var lapCounter = 0
    private var locationManager = LocationManager()
    private var deviceManager = DeviceManager()
    
    //var devTypeMap = [CBPeripheral:DeviceType]();
    
    private var container: NSPersistentContainer!
    
    @IBOutlet weak var lblWatts: UILabel!
    @IBOutlet weak var lblHeartRate: UILabel!
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblRideTime: UILabel!
    @IBOutlet weak var lblClock: UILabel!
    @IBOutlet weak var lblLap: UILabel!
    @IBOutlet weak var lblLapWatts: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnLap: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clock = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(clockCode), userInfo: nil, repeats: true)
        rideTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        clockCode()
        locationManager.startLocationUpdates()
    }
    
    @objc func clockCode() {
        let currentDateTime = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "HH:mm"
        
        lblClock.text = "\(dateFormatter.string(from: currentDateTime))"
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rideTimer?.invalidate()
        locationManager.stopUpdatingLocation()
        
    }
    
    func startTimer() {
    }
    
    func stopTimer() {
        //        rideTimer?.invalidate()
        //        rideTimer = nil
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
        }
    }
    
    @objc func runTimedCode() {
        
        let end = DispatchTime.now()

        lblWatts.text = String(deviceManager.watts)
        lblHeartRate.text = String(deviceManager.heartRate)
        lblSpeed.text = String(locationManager.speed)
        
        if timerIsPaused == false {
            saveRide()
            if let tmpStartTime = startTime {
                let nanoTime = end.uptimeNanoseconds - tmpStartTime.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                let timeInterval = Double(nanoTime) / 1_000_000_000
                
                let hours = Int(timeInterval) / 3600
                let minutes = Int(timeInterval) / 60 % 60
                let seconds = Int(timeInterval) % 60
                lblRideTime.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
            }
        }
    }
    
    private func saveRide() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let newRide = Ride(context: context)
        
        newRide.distance = locationManager.distance.value
        newRide.duration = Int16(seconds)
        newRide.timestamp = Date()
        newRide.heartrate = Int16(deviceManager.heartRate)
        newRide.lap = Int16(lapCounter)
        
        for location in locationManager.locationList {
            let locationObject = Location(context: context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRide.addToLocations(locationObject)
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
