//
//  PeripheralData.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-09-22.
//

import Foundation


struct DeviceInfo {
    var uuid:String?
    var name:String?
    var description:String?
}

public enum DeviceType: String {
    case HeartRate = "HeartRate";
    case SpeedCadence = "SpeedCadence";
    case PowerMeter = "PowerMeter";
    case UNKNOWN = "Unknown";
}

public class PeripheralData: NSObject {
    var speed:Double = 0.0;
    var heartRate = 0
    var power: Int = 0
    var cadence:Int = 0;
    var timeStamp = Date()
    var deviceType = DeviceType.PowerMeter
    var previousCrankTimeEvent  = 0.0
    var previousCrankCount = 0.0
    var lap = 0
    var powerEvent = false
    var hrEvent = false
    var gps: GPSData = GPSData()
}
