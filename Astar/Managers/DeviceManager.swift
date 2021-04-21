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
let powerMeterMeasurementFeatureCBUUID = CBUUID(string: POWER_FEATURE)
let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")
let powerMeterServiceCBUUID = CBUUID(string: "1818")
let deviceInfoServiceUUID = CBUUID(string: "180A")
let batteryServiceUUID = CBUUID(string: "180F")
let batteryCharacteristic = CBUUID(string: BATTERY_LEVEL)
let manufactureServiceUUID = CBUUID(string: MANUFACTURER_NAME)
let manufactureServiceModelUUID = "Manufacturer Name String"

let POWER_CONTROL = "2A66"
let POWER_MEASUREMENT = "2A63"
let POWER_FEATURE = "2A65"
let BATTERY_LEVEL = "2A19"
let BATTERY_LEVEL_STATE = "2A1B"
let MANUFACTURER_NAME = "2A29"

let POWER_CRANK:UInt8 = 44
let POWER_DUAL_CRANK_1:UInt8 = 47
let POWER_DUAL_CRANK_2:UInt8 = 45
let POWER_TRAINER:UInt8 = 39
let POWER_HUB:UInt8 = 52

class DeviceManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //private var aPeripheral: CBPeripheral!
    private var centralManager: CBCentralManager!
    private var reading: PeripheralData!
    
    private var peripheralsInUse: [CBPeripheral]!
    
    private var calibPeripheral: CBPeripheral!
    private var calibCharacteristic: CBCharacteristic!
    
    //Devices Saved for regular use
    var savedDevices: [String] = []
    private var devices: [DeviceInfo]!
    
    //Devices that were scanned during full scan but not saved
    var scannedDevicesStrings: [String] = []
    private var scannedDevices: [CBPeripheral]!
    
    private var MAX_SCAN_TIMER = 300
    
    private var scanTimer: Timer?
    
    var rideDelegate: RideDelegate?
    var bleDelegate: BluetoothDelegate?
    var fullScan = false
    
    var leftWatts:Int = 0
    var rightWatts:Int = 0
    var cadence = 0.0
    
   
    var deviceCount = 0
    
    static let deviceManagerInstance = DeviceManager()
    
    override init() {
        super.init()
        
        reading = PeripheralData()
        devices = [DeviceInfo]()
        scannedDevices = [CBPeripheral]()
        peripheralsInUse = [CBPeripheral]()
        
        let defaults = UserDefaults.standard
        savedDevices = defaults.object(forKey:"saved_devices") as? [String] ?? [String]()
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Dropped Device: \(String(describing: peripheral.name?.debugDescription))");
        
        print("Error: \(String(describing: error))")
        
        if savedDevices.firstIndex(of: peripheral.identifier.uuidString) != nil {
            centralManager.connect(peripheral, options: nil)
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
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID, powerMeterServiceCBUUID, deviceInfoServiceUUID, batteryServiceUUID])
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
    
    
    func calibratePowermeter() {
        
        //var rawArray:[UInt8] = [0x0C]
        var rawArray:[UInt8] = [0x10];
        let data = NSData(bytes: &rawArray, length: rawArray.count)
        calibPeripheral.writeValue(data as Data, for: calibCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Peripheral Found: \(peripheral.identifier.uuidString)")
        
        if !fullScan {
            if savedDevices.firstIndex(of: peripheral.identifier.uuidString) != nil {
                
                peripheral.delegate = self
                peripheralsInUse.append(peripheral)
                centralManager.connect(peripheral, options: nil)
            }
        } else {
            peripheral.delegate = self
            scannedDevices.append(peripheral)
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func stopScanning() {
        if centralManager != nil && centralManager.state == .poweredOn && centralManager.isScanning {
            print("Stop scanning")
            scannedDevices.removeAll()
            scannedDevicesStrings.removeAll()
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
                //let tmpPeripheral = devices[index]
                //centralManager.cancelPeripheralConnection(tmpPeripheral)
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
        //peripheral.discoverServices([heartRateServiceCBUUID, powerMeterServiceCBUUID, deviceInfoServiceUUID, batteryServiceUUID])
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            // print("Services: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        //print("Found peripheral: \(service.peripheral.identifier.uuidString)")
        // print("Service UUID Found: \(service.uuid)")
        switch service.uuid {
        case heartRateServiceCBUUID:
            
            print("Found a Heart Rate Monitor")
            
            var deviceInfo = DeviceInfo()
            deviceInfo.uuid = service.uuid.uuidString
            deviceInfo.description = "Heart Rate Monitor"
            deviceInfo.name = peripheral.name
            deviceInfo.device = peripheral
            
            devices.append(deviceInfo)
            
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
        case powerMeterServiceCBUUID:
            
            var deviceInfo = DeviceInfo()
            deviceInfo.uuid = service.uuid.uuidString
            deviceInfo.description = "Power Meter"
            deviceInfo.name = peripheral.name
            deviceInfo.device = peripheral
            
            devices.append(deviceInfo)
            
            print("Found a power meter")
            
            for characteristic in service.characteristics! as [CBCharacteristic] {
                switch characteristic.uuid.uuidString {
                case POWER_CONTROL:
                    print("POWER CONTROL")
                    if characteristic.uuid.uuidString == "2A66" {
                        calibPeripheral = peripheral
                        calibCharacteristic = characteristic
                    }

                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                case POWER_MEASUREMENT:
                    if characteristic.properties.contains(.notify) {
                        print("POWER MEASUREMENT")
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                case POWER_FEATURE:
                    if characteristic.properties.contains(.notify) {
                        print("POWER FEATURE")
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    if characteristic.properties.contains(.read) {
                        print("\(characteristic.uuid): properties contains .read")
                        peripheral.readValue(for: characteristic)
                    }
                default:
                    print(characteristic)
                  //  peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            
        case batteryServiceUUID:
            for characteristic in service.characteristics! as [CBCharacteristic] {
                switch characteristic.uuid.uuidString {
                case BATTERY_LEVEL:
                    print("BATTERY_LEVEL")
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    if characteristic.properties.contains(.read) {
                        print("\(characteristic.uuid): properties contains .read")
                        peripheral.readValue(for: characteristic)
                    }
                case BATTERY_LEVEL_STATE:
                    print("BATTERY_STATE")
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    if characteristic.properties.contains(.read) {
                        print("\(characteristic.uuid): properties contains .read")
                        peripheral.readValue(for: characteristic)
                    }
                default:
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                }
            }
        case deviceInfoServiceUUID:
            for characteristic in service.characteristics! as [CBCharacteristic] {
                switch characteristic.uuid.uuidString {
                case MANUFACTURER_NAME:
                    print("MANUFACTURER_NAME")
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    if characteristic.properties.contains(.read) {
                        print("\(characteristic.uuid): properties contains .read")
                        peripheral.readValue(for: characteristic)
                    }
                default:
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                }
            }
        case batteryServiceUUID:
            for characteristic in service.characteristics! as [CBCharacteristic] {
                if characteristic.properties.contains(.read) {
                    print("\(characteristic.uuid): properties contains .read")
                    peripheral.readValue(for: characteristic)
                }
            }
        default:
            for characteristic in service.characteristics! as [CBCharacteristic] {
                peripheral.setNotifyValue(true, for: characteristic)
                //print("unhandled service: \(service.uuid.uuidString) unhandled characteristic: \(characteristic.uuid.uuidString)")
            }
        }
    }
    
    func updateBattery(_ peripheral:CBPeripheral, value:Data){
        
        var buffer = [UInt8](repeating: 0x00, count: value.count)
        value.copyBytes(to: &buffer, count: buffer.count)
        
        let batlevel = UInt8(buffer[0])
        let batteryLevel = Int16(batlevel)
        print("Battery Level: \(batteryLevel)%")
        
    }
    
    func updatePower(from characteristic: CBCharacteristic) {
        
        guard let characteristicData = characteristic.value else { return }

        var crankRev = 0.0
        var crankTime = 0.0
        
        var leftPercent = 0.0
        var rightPercent = 0.0

        var watts = 0
        var cadence = 0
        
        var powerEvent = false
        var cadenceEvent = false
        
        updatePowerMeterValues(value: characteristicData)
        
        let n = devices.firstIndex { $0.device == characteristic.service.peripheral }
        let device = devices[n!]
        
        // the first 16bits contains the data for the flags
        // The next 16bits make up the power reading
        let byteArray = [UInt8](characteristicData)
        print(byteArray)
        
        switch byteArray[0] {
        case POWER_CRANK:
            let byteArray1 = Int(byteArray[2])
            let byteArray2 = Int(byteArray[3])
            let overFlow = byteArray2 * 255
            watts = byteArray1+overFlow
            
            crankRev = Double(byteArray[6]) + (Double(byteArray[7]) * 255.0)
            crankTime = Double((UInt16(byteArray[9]) << 8) + UInt16(byteArray[8]))
            
            powerEvent = true
            cadenceEvent = true
            
        case POWER_TRAINER:
            let byteArray1 = Int(byteArray[2])
            let byteArray2 = Int(byteArray[3])
            let overFlow = byteArray2 * 255
            watts = byteArray1+overFlow
            
            crankRev = Double(byteArray[11]) + Double((byteArray[12]) * 255)
            crankTime = Double((UInt16(byteArray[14]) << 8) + UInt16(byteArray[13]))
            
            powerEvent = true
            cadenceEvent = true
            
        case POWER_HUB:
            let byteArray1 = Int(byteArray[2])
            let byteArray2 = Int(byteArray[3])
            let overFlow = byteArray2 * 255
            watts = byteArray1+overFlow
            
            powerEvent = true
            cadenceEvent = true
            
        case POWER_DUAL_CRANK_1:
            let byteArray1 = Int(byteArray[2])
            let byteArray2 = Int(byteArray[3])
            let overFlow = byteArray2 * 255
            leftWatts = byteArray1+overFlow
            
            if (device.pedalPowerBalancePresent) {
                leftPercent = Double(byteArray[4])
                print("Left Right Balance CRANK1: \(leftPercent)")
                rightPercent = abs(leftPercent - 100)
                watts = leftWatts
                
            } else {
                watts = (leftWatts + rightWatts)
                if watts != 0 {
                    leftPercent = Double(Double(leftWatts) / Double(watts)) * 100.0
                    rightPercent = abs(leftPercent - 100)
                }
            }
            
            crankRev = Double(byteArray[7]) + (Double(byteArray[8]) * 255.0)
            crankTime = Double((UInt16(byteArray[10]) << 8) + UInt16(byteArray[9]))
            
            powerEvent = true
            
            
        case POWER_DUAL_CRANK_2:
            let byteArray1 = Int(byteArray[2])
            let byteArray2 = Int(byteArray[3])
            let overFlow = byteArray2 * 255
            rightWatts = byteArray1+overFlow
            
            watts = rightWatts
            
            if (device.pedalPowerBalancePresent) {
                rightPercent = Double(byteArray[4])
                print("Right Percent CRANK 2: \(rightPercent)")
                leftPercent = abs(rightPercent - 100)
                print("Left Percent CRANK 2: \(leftPercent)")

            } else {
                watts = (leftWatts + rightWatts)
                if watts != 0 {
                    rightPercent = Double(Double(rightWatts) / Double(watts)) * 100.0
                    leftPercent = abs(rightPercent - 100)
                }
            }
            
            powerEvent = true
            
        default:
            return
        }
        
        //This is for cadence
        if byteArray[0] != POWER_DUAL_CRANK_2 {
            let cumulativeRevs = rollOver(current: crankRev, previous: reading.previousCrankCount, max: UInt16.max)
            let cumulativeTime = rollOver(current: crankTime, previous: reading.previousCrankTimeEvent, max: UInt16.max)
            
            if (reading.previousCrankTimeEvent != crankTime) || (reading.previousCrankCount != crankRev) {
                if cumulativeTime != 0 {
                    cadence = Int(Double((60 * cumulativeRevs / cumulativeTime) * 1024 ))
                    cadenceEvent = true
                }
            }
            
        }
        //Store the values and pass it along.
        reading.power = Int(watts)
        reading.deviceType = DeviceType.PowerMeter
        reading.powerEvent = powerEvent
        reading.cadence = cadence
        reading.cadenceEvent = cadenceEvent
        reading.leftPercent = leftPercent
        reading.rightPercent = rightPercent

        updateRide(ride: reading)
        
        let prevCrankCount = reading.previousCrankCount
        let prevCrankTimeEvent = reading.previousCrankTimeEvent
        reading = PeripheralData()
        
        if byteArray[0] != POWER_DUAL_CRANK_2 {
            if crankRev > reading.previousCrankCount {
                reading.previousCrankCount = crankRev
                reading.previousCrankTimeEvent = crankTime
            }
        } else {
            reading.previousCrankCount = prevCrankCount
            reading.previousCrankTimeEvent = prevCrankTimeEvent
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
        
        // print("characteristic UUID: \(characteristic.uuid.uuidString)")
        
        switch characteristic.uuid {
        case heartRateMeasurementCharacteristicCBUUID:
            updateHeartRate(from: characteristic)
        case powerMeterMeasurementCharacteristicCBUUID:
            updatePower(from: characteristic)
        case batteryCharacteristic:
            updateBattery(peripheral, value: characteristic.value!)
        case manufactureServiceUUID:
            print("Manufacture Service: \(String(describing: characteristic.value))");
        //case manufactureServiceModelUUID:
        //    print("\(String(describing: characteristic.value))");
        case powerMeterMeasurementFeatureCBUUID:
            updatePowerMeterFeatures(peripheral, value: characteristic.value!)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        //            let chara = characteristic.uuid
        //            print("Chara String: \(chara.uuidString)")
        }
    }
    func updatePowerMeterFeatures(_ peripheral:CBPeripheral, value: Data)
    {
        let features = readFeatures(value)
        print("AccumulatedEnergySupported \(features.contains(.AccumulatedEnergySupported))")
        print("AccumulatedTorqueSupported \(features.contains(.AccumulatedTorqueSupported))")
        print("ChainLengthAdjustmentSupported \(features.contains(.ChainLengthAdjustmentSupported))")
        print("ChainWeightAdjustmentSupported \(features.contains(.ChainWeightAdjustmentSupported))")
        print("ContentMaskingSupported \(features.contains(.ContentMaskingSupported))")
        print("CrankLengthAdjustmentSupported \(features.contains(.CrankLengthAdjustmentSupported))")
        print("CrankRevolutionDataSupported \(features.contains(.CrankRevolutionDataSupported))")
        print("ExtremeAnglesSupported \(features.contains(.ExtremeAnglesSupported))")
        print("ExtremeMagnitudesSupported \(features.contains(.ExtremeMagnitudesSupported))")
        print("FactoryCalibrationDateSupported \(features.contains(.FactoryCalibrationDateSupported))")
        print("InstantaneousMeasurementDirectionSupported \(features.contains(.InstantaneousMeasurementDirectionSupported))")
        print("MultipleSensorLocationsSupported \(features.contains(.MultipleSensorLocationsSupported))")
        print("OffsetCompensationIndicatorSupported \(features.contains(.OffsetCompensationIndicatorSupported))")
        print("OffsetCompensationSupported \(features.contains(.OffsetCompensationSupported))")
        print("PedalPowerBalanceSupported \(features.contains(.PedalPowerBalanceSupported))")
        print("SensorMeasurementContext \(features.contains(.SensorMeasurementContext))")
        print("SpanLengthAdjustmentSupported \(features.contains(.SpanLengthAdjustmentSupported))")
        print("TopAndBottomDeadSpotAnglesSupported \(features.contains(.TopAndBottomDeadSpotAnglesSupported))")
        print("WheelRevolutionDataSupported \(features.contains(.WheelRevolutionDataSupported))")

     
        let n = devices.firstIndex { $0.device == peripheral }
        devices[n!].pedalPowerBalancePresent = features.contains(.PedalPowerBalanceSupported)
    }
    
    func updatePowerMeterValues(value:Data){
        var index: Int = 0
        let bytes = value.map { $0 }
        let rawFlags: UInt16 = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
        let flags = MeasurementFlags(rawValue: rawFlags)
        
        /*
        print("AccumulatedEnergyPresent \(flags.contains(.AccumulatedEnergyPresent))")
        print("AccumulatedTorquePresent \(flags.contains(.AccumulatedTorquePresent))")
        print("BottomDeadSpotAnglePresent \(flags.contains(.BottomDeadSpotAnglePresent))")
        print("CrankRevolutionDataPresent \(flags.contains(.CrankRevolutionDataPresent))")
        print("ExtremeAnglesPresent \(flags.contains(.ExtremeAnglesPresent))")
        print("ExtremeForceMagnitudesPresent \(flags.contains(.ExtremeForceMagnitudesPresent))")
        print("ExtremeTorqueMagnitudesPresent \(flags.contains(.ExtremeTorqueMagnitudesPresent))")
       
        print("OffsetCompensationIndicator \(flags.contains(.OffsetCompensationIndicator))")
        
        print("PedalPowerBalancePresent \(flags.contains(.PedalPowerBalancePresent))")
        print("TopDeadSpotAnglePresent \(flags.contains(.TopDeadSpotAnglePresent))")
        print("WheelRevolutionDataPresent \(flags.contains(.WheelRevolutionDataPresent))")
    
         */
        if flags.contains(.OffsetCompensationIndicator) {
            print("BINGO!!!!")
        }
        
        
    }
    
    public func readFeatures(_ data: Data) -> Features {
        let bytes = data.map { $0 }
        var rawFeatures: UInt32 = 0
        if bytes.count > 0 { rawFeatures |= UInt32(bytes[0]) }
        if bytes.count > 1 { rawFeatures |= UInt32(bytes[1]) << 8 }
        if bytes.count > 2 { rawFeatures |= UInt32(bytes[2]) << 16 }
        if bytes.count > 3 { rawFeatures |= UInt32(bytes[3]) << 24 }
        return Features(rawValue: rawFeatures)
    }
    
    private func updateHeartRate(from characteristic: CBCharacteristic) {
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        var heartRate = 0
        
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
