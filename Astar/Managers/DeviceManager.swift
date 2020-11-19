//
//  Devices.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-09-22.
//

import Foundation
import CoreBluetooth


let heartRateServiceCBUUID = CBUUID(string: "0x180D")
let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
let powerMeterMeasurementCharacteristicCBUUID = CBUUID(string: POWER_MEASUREMENT)
let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")
let powerMeterServiceCBUUID = CBUUID(string: "1818")
let POWER_CONTROL = "2A66"
let POWER_MEASUREMENT = "2A63"
let POWER_FEATURE = "2A65"

let POWER_CRANK = 44
let POWER_TRAINER = 39

class DeviceManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var peripheral: CBPeripheral!
    private var centralManager: CBCentralManager!
    private var reading: PeripheralData!
    private var devices: [CBPeripheral]!
    
    private var MAX_SCAN_TIMER = 300
    
    private var scanTimer: Timer?
    
    var rideDelegate: RideDelegate?
    var bleDelegate: BluetoothDelegate?
    var fullScan = false
    
    var savedDevices: [String] = []
    
    var deviceCount = 0
    
    static let deviceManagerInstance = DeviceManager()
    
    override init() {
        super.init()
        
        reading = PeripheralData();
        devices = [CBPeripheral]()
        
        let defaults = UserDefaults.standard
        savedDevices = defaults.object(forKey:"saved_devices") as? [String] ?? [String]()
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Dropped Connection!")
        print("Dropped Name: \(peripheral.name)");
        print("Dropped UUID: \(peripheral.identifier.uuidString)")
        
        if let index = savedDevices.firstIndex(of: peripheral.identifier.uuidString) {
            
            savedDevices.remove(at: index)
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID, powerMeterServiceCBUUID])
            
        }
    }
    
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
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID, powerMeterServiceCBUUID])
        @unknown default:
            print("Unknown case")
        }
    }
    
    func startScanning(fullScan: Bool) {
        print("Start Scanning")
        self.fullScan = fullScan
        scanTimer = Timer.scheduledTimer(timeInterval: TimeInterval(MAX_SCAN_TIMER), target: self, selector: #selector(scanTimeCode), userInfo: nil, repeats: false)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @objc func scanTimeCode() {
        
        stopScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover tmpPeripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {

        peripheral = tmpPeripheral
        peripheral.delegate = self
        centralManager.connect(peripheral)
        
        if fullScan == false {
            if let _ = savedDevices.firstIndex(of: tmpPeripheral.identifier.uuidString) {
              
                devices.append(peripheral)
            }
        }
    }
    
    func stopScanning() {
        if centralManager != nil && centralManager.state == .poweredOn && centralManager.isScanning {
            print("Stop scanning")
            centralManager.stopScan()
        }
    }
    
    func saveDevice(deviceID: String, state: Bool) {
        let defaults = UserDefaults.standard
        if state {
            savedDevices.append(deviceID)
        } else {
            if let index = savedDevices.firstIndex(of: deviceID) {
                savedDevices.remove(at: index)
                let tmpPeripheral = devices[index]
                centralManager.cancelPeripheralConnection(tmpPeripheral)
            }
        }
        defaults.set(savedDevices, forKey: "saved_devices")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("Device: \(String(describing: peripheral.name))")
        
        if fullScan {
            var ble = BluetoothData()
            ble.description = peripheral.identifier.description
            ble.id = peripheral.identifier.uuidString
            ble.name = peripheral.name?.debugDescription
            updateBluetooth(ble: ble)
        } else {
            if savedDevices.firstIndex(of: peripheral.identifier.uuidString) != nil {
                deviceCount = deviceCount + 1
            }
        }
        peripheral.discoverServices([heartRateServiceCBUUID, powerMeterServiceCBUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("Services: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        if let _ = savedDevices.firstIndex(of: service.peripheral.identifier.uuidString) {
            
            if service.uuid == heartRateServiceCBUUID {
                
                print("Found a Heart Rate Monitor")
                
                var deviceInfo = DeviceInfo()
                deviceInfo.uuid = service.uuid.uuidString
                deviceInfo.description = "Heart Rate Monitor"
                deviceInfo.name = peripheral.name
                
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
            } else if service.uuid == powerMeterServiceCBUUID {
                
                var deviceInfo = DeviceInfo()
                deviceInfo.uuid = service.uuid.uuidString
                deviceInfo.description = "Power Meter"
                deviceInfo.name = peripheral.name
                
                print("Found a power meter")
                
                for characteristic in service.characteristics! as [CBCharacteristic] {
                    print(characteristic)
                    
                    switch characteristic.uuid.uuidString {
                    case POWER_CONTROL:
                        var rawArray:[UInt8] = [0x01];
                        let data = NSData(bytes: &rawArray, length: rawArray.count)
                        peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                        print("POWER CONTROL")
                    case POWER_MEASUREMENT:
                        if characteristic.properties.contains(.notify) {
                            print("POWER MEASUREMENT")
                            peripheral.setNotifyValue(true, for: characteristic);
                        }
                    // this should set the cumulative count back to zero
                    case POWER_FEATURE:
                        if characteristic.properties.contains(.notify) {
                            print("POWER FEATURE")
                            peripheral.setNotifyValue(true, for: characteristic);
                        }
                    default:
                        peripheral.setNotifyValue(true, for: characteristic);
                    }
                }
            }
        }
    }
    
    func updatePower(from characteristic: CBCharacteristic) {
        
        var cadence = 0.0
        guard let characteristicData = characteristic.value else { return }
        
        var crankRev = 0.0
        var crankTime = 0.0
        var watts:Int = 0
        
        var crankEvent = false
        
        
        // the first 16bits contains the data for the flags
        // The next 16bits make up the power reading
        let byteArray = [UInt8](characteristicData)
        
        if byteArray[0] == POWER_CRANK {
            
            let byteArray1 = Int(byteArray[2])
            let byteArray2 = Int(byteArray[3])
            let overFlow = byteArray2 * 255
            watts = byteArray1+overFlow
            
            crankRev = Double(byteArray[6]) + (Double(byteArray[7]) * 255.0)
            crankTime = Double((UInt16(byteArray[9]) << 8) + UInt16(byteArray[8]))
            
            crankEvent = true
            
        } else if byteArray[0] == POWER_TRAINER {
            
            let byteArray1 = Int(byteArray[2])
            let byteArray2 = Int(byteArray[3])
            let overFlow = byteArray2 * 255
            watts = byteArray1+overFlow
            
            crankRev = Double(byteArray[11]) + Double((byteArray[12]) * 255)
            crankTime = Double((UInt16(byteArray[14]) << 8) + UInt16(byteArray[13]))
            
            crankEvent = true
        } else {
            return
        }
        
        let cumulativeRevs = rollOver(current: crankRev, previous: reading.previousCrankCount, max: UInt16.max)
        let cumulativeTime = rollOver(current: crankTime, previous: reading.previousCrankTimeEvent, max: UInt16.max)
        
        
        if (reading.previousCrankTimeEvent != crankTime) || (reading.previousCrankCount != crankRev) {
            if cumulativeTime != 0 {
                cadence = Double((60 * cumulativeRevs / cumulativeTime) * 1024 )
            }
        }
        
        reading.power = Int(watts)
        reading.cadence = Int(cadence)
        reading.deviceType = DeviceType.PowerMeter
        reading.powerEvent = crankEvent
        
        updateRide(ride: reading)
        
        reading = PeripheralData()
        
        if crankRev > reading.previousCrankCount {
            reading.previousCrankCount = crankRev
            reading.previousCrankTimeEvent = crankTime
        }
    }
    
    func rollOver(current: Double, previous: Double, max: UInt16) -> Double {
        if current >= previous {
            return current - previous
        } else {
            return (Double(max) - previous) + current
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case heartRateMeasurementCharacteristicCBUUID:
            updateHeartRate(from: characteristic)
        case powerMeterMeasurementCharacteristicCBUUID:
            updatePower(from: characteristic)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func updateHeartRate(from characteristic: CBCharacteristic) {
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        var heartRate = 0
        
        // See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml
        // The heart rate mesurement is in the 2nd, or in the 2nd and 3rd bytes, i.e. one one or in two bytes
        // The first byte of the first bit specifies the length of the heart rate data, 0 == 1 byte, 1 == 2 bytes
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            heartRate = Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            heartRate = (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
        
        reading.heartRate = heartRate
        reading.hrEvent = true
        updateRide(ride: reading)
    }
    
    func updateRide(ride: PeripheralData) {
        rideDelegate?.didNewRideData(self, ride: ride)
    }
    
    func updateBluetooth(ble: BluetoothData) {
        bleDelegate?.didNewBLEUpdate(self, ble: ble)
    }
}

extension DefaultStringInterpolation {
    mutating func appendInterpolation<T>(optional: T?) {
        appendInterpolation(String(describing: optional))
    }
}
