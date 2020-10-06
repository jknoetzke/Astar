//
//  PeripheralData.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-09-22.
//

import Foundation

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
    var instantTimestamp:Date!
    var deviceType = DeviceType.PowerMeter
    var previousCrankTimeEvent  = 0.0
    var previousCrankCount = 0.0
    var distance = 0.0
    var location:Location!
    var altitude = 0.0
    var lap = 0
}
