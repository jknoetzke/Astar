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
let POWER_CONTROL = "2A66";
let POWER_MEASUREMENT = "2A63";
let POWER_FEATURE = "2A65";


class DeviceManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var peripheral: CBPeripheral!
    private var centralManager: CBCentralManager!
    private var reading = PeripheralData();
    var heartRate = 0
    var watts = 0;
    
    var cadence: Int16 = 0
    
    var ts1: UInt16 = 0
    var ts2: UInt16 = 0
    
    var cad1: UInt16 = 0
    var cad2: UInt16 = 0
    
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
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
    
    func updatePower(from characteristic: CBCharacteristic) -> Int {
        
        guard let characteristicData = characteristic.value else { return -1 }
        
        // the first 16bits contains the data for the flags
        // The next 16bits make up the power reading
        let byteArray = [UInt8](characteristicData)
        let watts:Int = Int(byteArray[2]) + Int((byteArray[3]) * 255)
        
        let crankRev = (UInt16(byteArray[8]) << 8) + UInt16(byteArray[7])
        let crankTime = (UInt16(byteArray[10]) << 8) + UInt16(byteArray[9])

        
       // print("Crank: \(crankRev)")
      //  print("Time: \(crankTime)")
        
        var cumulativeRevs = 0.0
        var cumulativeTime = 0.0

        if crankRev < cad1 {
            let dCad1 = Double(cad1)
            let dCrankRev = Double(crankRev)
            cumulativeRevs =  dCad1 - dCrankRev
        } else {
            cumulativeRevs = 0
        }
        if crankTime < ts1 {
            let dTs1 = Double(ts1)
            let dCrankTime = Double(crankTime)
            cumulativeTime = dTs1 - dCrankTime
        } else {
            cumulativeTime = 0
        }
        
       // print("cumRevs: \(cumulativeRevs)")
       // print("cumTime: \(cumulativeTime)")
        
        if cumulativeTime != 0 {
            let raw = Double(cumulativeRevs / cumulativeTime)
            let cadence = Int16(Int(raw * 60))
            
            //print("Cadence: \(cadence)")
        }
        
        if ts2 != crankTime {
            ts2 = crankTime
            //ts1 = ts1 + crankTime
        }
        
        if cad2 != crankRev {
            cad2 = crankRev
            cad1 = cad1 + crankRev
        }
        
        reading.currentValue = Int(watts)
        reading.deviceType = DeviceType.PowerMeter
        reading.instantTimestamp = NSDate().timeIntervalSince1970
        
        print("Watts: \(watts)")
        
        return watts
    }
    
    
    func onHeartRateReceived(_ heartRate: Int) {
        print("BPM: \(heartRate)")
        self.heartRate = heartRate
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm)
        case powerMeterMeasurementCharacteristicCBUUID:
            let watts = updatePower(from: characteristic)
            onPowerReceived(watts)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func onPowerReceived(_ tmpWatts: Int) {
        self.watts = tmpWatts
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
}
