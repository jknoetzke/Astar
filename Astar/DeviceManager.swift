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
let UINT16_MAX = 65536.0


class DeviceManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var peripheral: CBPeripheral!
    private var centralManager: CBCentralManager!
    private var reading: PeripheralData!;
    
    var delegate: RideDelegate?
    
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        reading = PeripheralData();
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
    
    func centralManager(_ central: CBCentralManager, didDiscover tmpPeripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(tmpPeripheral)
        peripheral = tmpPeripheral
        peripheral.delegate = self
        //centralManager.stopScan()
        centralManager.connect(peripheral)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        peripheral.discoverServices([heartRateServiceCBUUID, powerMeterServiceCBUUID])
        
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        if service.uuid == heartRateServiceCBUUID {
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
            
            print("Found a power meter")
            //self.devTypeMap[peripheral] = DeviceType.PowerMeter;
            // we should update the saved devices
            //self.updateDevice(peripheral, deviceTyp: DeviceType.PowerMeter);
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
    
    func updatePower(from characteristic: CBCharacteristic) {
        
        var cadence = 0.0
        guard let characteristicData = characteristic.value else { return }
        
        // the first 16bits contains the data for the flags
        // The next 16bits make up the power reading
        let byteArray = [UInt8](characteristicData)
        let watts:Int = Int(byteArray[2]) + Int((byteArray[3]) * 255)
        
        let crankRev:Double = Double(byteArray[11]) + Double((byteArray[12]) * 255)
        let crankTime:Double = Double((UInt16(byteArray[14]) << 8) + UInt16(byteArray[13]))
        
        let cumulativeRevs = rollOver(current: crankRev, previous: reading.previousCrankCount, max: UINT16_MAX)
        let cumulativeTime = rollOver(current: crankTime, previous: reading.previousCrankTimeEvent, max: UINT16_MAX)
        
        if (reading.previousCrankTimeEvent != crankTime) || (reading.previousCrankCount != crankRev) {
            if cumulativeTime != 0 {
                cadence = Double((60 * cumulativeRevs / cumulativeTime) * 1024 )
                print("Cadence: \(cadence)")
            }
        }
        
        if crankRev > reading.previousCrankCount {
            reading.previousCrankCount = crankRev
            reading.previousCrankTimeEvent = crankTime
        }
        
        reading.power = Int(watts)
        reading.cadence = Int(cadence)
        reading.deviceType = DeviceType.PowerMeter
        reading.instantTimestamp = NSDate().timeIntervalSince1970
        
        updateRide(ride: reading)
    }
    
    func rollOver(current: Double, previous: Double, max: Double) -> Double {
        if current >= previous {
            return current - previous
        } else {
            return (max - previous) + current
        }
    }
    
    func onHeartRateReceived(_ heartRate: Int) {
        print("BPM: \(heartRate)")
        reading.heartRate = heartRate
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
        updateRide(ride: reading)
    }
    
    func updateRide(ride: PeripheralData) {
        delegate?.didNewRideData(self, ride: ride)
    }
}
