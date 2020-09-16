
import UIKit
import CoreBluetooth
import CoreLocation
import CoreData

let heartRateServiceCBUUID = CBUUID(string: "0x180D")
let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")

class ViewController: UIViewController {
    
    private var centralManager: CBCentralManager!
    private var heartRatePeripheral: CBPeripheral!
    private var rideTimer: Timer?
    private var clock: Timer?
    private let locationManager = CLLocationManager()
    private var seconds = 0
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    private var heartRate = 0
    private var speed = 0.0;
    private var startTime: DispatchTime?
    private var watts = 0
    private var timerIsPaused = true
    private var lapCounter = 0
    
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
        clockCode() //Set the time
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    @objc func clockCode() {
        let currentDateTime = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "HH:MM"

        lblClock.text = "\(dateFormatter.string(from: currentDateTime))"

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rideTimer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    func startTimer() {
        timerIsPaused = false
        rideTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)

    }
    
    func stopTimer() {
        timerIsPaused = true
        rideTimer?.invalidate()
        rideTimer = nil
    }
    
    @IBAction func lapClicked(_ sender: Any) {
        
        lapCounter = lapCounter + 1
        lblLap.text = String(lapCounter)
    }
    @IBAction func startClicked(_ sender: Any) {

        
        if timerIsPaused {
            startTimer()
            startLocationUpdates()
            startTime = DispatchTime.now()
            let hours = 0
            let minutes = 0
            let seconds = 0
            lblRideTime.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
            
            btnLap.isEnabled = true
            
            if let stopImage = UIImage(systemName: "stop") {
                btnStart.setImage(stopImage, for: .normal)
                btnStart.setTitle("Stop", for: .normal)
            }
        } else {
            stopTimer()
            if let startImage = UIImage(systemName: "play") {
                btnStart.setImage(startImage, for: .normal)
                btnStart.setTitle("Start", for: .normal)
                locationManager.stopUpdatingLocation()
            }
            btnLap.isEnabled = false

        }
        
    }
    
   
    func onHeartRateReceived(_ heartRate: Int) {
        print("BPM: \(heartRate)")
        self.heartRate = heartRate
    }
    
    @objc func runTimedCode() {
        
        let end = DispatchTime.now()
        
        if let tmpStartTime = startTime {
            let nanoTime = end.uptimeNanoseconds - tmpStartTime.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
            let timeInterval = Double(nanoTime) / 1_000_000_000
            
            let hours = Int(timeInterval) / 3600
            let minutes = Int(timeInterval) / 60 % 60
            let seconds = Int(timeInterval) % 60
            lblRideTime.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        }
        
        lblWatts.text = String(watts)
        lblHeartRate.text = String(heartRate)
        lblSpeed.text = String(speed)
        
        saveRide()
    }
    
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
        @unknown default:
            print("Unknown case")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        heartRatePeripheral = peripheral
        heartRatePeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(heartRatePeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
    }
    
    
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        // See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml
        // The heart rate mesurement is in the 2nd, or in the 2nd and 3rd bytes, i.e. one one or in two bytes
        // The first byte of the first bit specifies the length of the heart rate data, 0 == 1 byte, 1 == 2 bytes
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 3
        locationManager.startUpdatingLocation()
    }
    
    private func saveRide() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let newRide = Ride(context: context)
        
        newRide.distance = distance.value
        newRide.duration = Int16(seconds)
        newRide.timestamp = Date()
        newRide.heartrate = Int16(heartRate)
        
        for location in locationList {
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

extension ViewController:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else {
                continue
            }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
            }
            
            speed = newLocation.speed
        }
    }
}
