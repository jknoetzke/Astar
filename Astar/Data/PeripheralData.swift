//
//  PeripheralData.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-09-22.
//

import Foundation
import CoreBluetooth


struct DeviceInfo {
    var uuid:String?
    var name:String?
    var description:String?
    var device: CBPeripheral?
    var pedalPowerBalancePresent = false
}

public class PeripheralData: NSObject {
    var rideID: UUID!
    var heartRate = 0
    var power: Int = 0
    var cadence:Int = 0;
    var timeStamp = Date()
    var previousCrankTimeEvent  = 0.0
    var previousCrankCount = 0.0
    var lap = 0
    var powerEvent = false
    var cadenceEvent = false
    var hrEvent = false
    var leftPercent = 0.0
    var rightPercent = 0.0
    var gps: GPSData = GPSData()
}
