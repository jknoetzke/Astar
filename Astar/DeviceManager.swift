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
let powerMeterServiceUUID = CBUUID(string: "1818")
let POWER_CONTROL = "2A66";
let POWER_MEASUREMENT = "2A63";
let POWER_FEATURE = "2A65";


class DeviceManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var heartRatePeripheral: CBPeripheral!
    private var centralManager: CBCentralManager!
    private var reading = PeripheralData();
    var heartRate = 0
    var watts = 0;
    
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
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID, powerMeterServiceUUID])
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
        } else if service.uuid == powerMeterServiceUUID {
            //self.devTypeMap[peripheral] = DeviceType.PowerMeter;
            // we should update the saved devices
            //self.updateDevice(peripheral, deviceTyp: DeviceType.PowerMeter);
            for characteristic in service.characteristics! as [CBCharacteristic] {
                switch characteristic.uuid.uuidString {
                case POWER_CONTROL:
                    var rawArray:[UInt8] = [0x01];
                    let data = NSData(bytes: &rawArray, length: rawArray.count)
                    peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                case POWER_MEASUREMENT:
                    peripheral.setNotifyValue(true, for: characteristic);
                // this should set the cumulative count back to zero
                case POWER_FEATURE:
                    peripheral.setNotifyValue(true, for: characteristic);
                default:
                    peripheral.setNotifyValue(true, for: characteristic);
                }
            }
            
        }
    }
    
    func updatePower(from characteristic: CBCharacteristic) -> Int16 {
       
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        let pwrReading = Int16(byteArray[1])

        reading.currentValue = pwrReading
        reading.deviceType = DeviceType.PowerMeter
        reading.instantTimestamp = NSDate().timeIntervalSince1970
        
        return pwrReading
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
    
    private func onPowerReceived(_ tmpWatts: Int16) {
        self.watts = Int(tmpWatts)
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
