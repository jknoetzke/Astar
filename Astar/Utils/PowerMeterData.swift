//
//  PowerMeterData.swift
//  Astar
//
//  Created by Justin Knoetzke on 2021-04-14.
//

import Foundation

struct MeasurementData {
    public var timestamp: Double = 0
    public var instantaneousPower: Int16 = 0
    public var pedalPowerBalance: UInt8?
    public var pedalPowerBalanceReference: Bool?
    public var accumulatedTorque: UInt16?
    
    public var cumulativeWheelRevolutions: UInt32?
    public var lastWheelEventTime: UInt16?
    
    public var cumulativeCrankRevolutions: UInt16?
    public var lastCrankEventTime: UInt16?
    
    public var maximumForceMagnitude: Int16?
    public var minimumForceMagnitude: Int16?
    public var maximumTorqueMagnitude: Int16?
    public var minimumTorqueMagnitude: Int16?
    public var maximumAngle: UInt16?
    public var minimumAngle: UInt16?
    public var topDeadSpotAngle: UInt16?
    public var bottomDeadSpotAngle: UInt16?
    public var accumulatedEnergy: UInt16?
}

struct Features: OptionSet {
    public let rawValue: UInt32
    
    public static let PedalPowerBalanceSupported                   = Features(rawValue: 1 << 0)
    public static let AccumulatedTorqueSupported                   = Features(rawValue: 1 << 1)
    public static let WheelRevolutionDataSupported                 = Features(rawValue: 1 << 2)
    public static let CrankRevolutionDataSupported                 = Features(rawValue: 1 << 3)
    public static let ExtremeMagnitudesSupported                   = Features(rawValue: 1 << 4)
    public static let ExtremeAnglesSupported                       = Features(rawValue: 1 << 5)
    public static let TopAndBottomDeadSpotAnglesSupported          = Features(rawValue: 1 << 6)
    public static let AccumulatedEnergySupported                   = Features(rawValue: 1 << 7)
    public static let OffsetCompensationIndicatorSupported         = Features(rawValue: 1 << 8)
    public static let OffsetCompensationSupported                  = Features(rawValue: 1 << 9)
    public static let ContentMaskingSupported                      = Features(rawValue: 1 << 10)
    public static let MultipleSensorLocationsSupported             = Features(rawValue: 1 << 11)
    public static let CrankLengthAdjustmentSupported               = Features(rawValue: 1 << 12)
    public static let ChainLengthAdjustmentSupported               = Features(rawValue: 1 << 13)
    public static let ChainWeightAdjustmentSupported               = Features(rawValue: 1 << 14)
    public static let SpanLengthAdjustmentSupported                = Features(rawValue: 1 << 15)
    public static let SensorMeasurementContext                     = Features(rawValue: 1 << 16)
    public static let InstantaneousMeasurementDirectionSupported   = Features(rawValue: 1 << 17)
    public static let FactoryCalibrationDateSupported              = Features(rawValue: 1 << 18)
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

struct MeasurementFlags: OptionSet {
    let rawValue: UInt16
    
    static let PedalPowerBalancePresent         = MeasurementFlags(rawValue: 1 << 0)
    static let AccumulatedTorquePresent         = MeasurementFlags(rawValue: 1 << 2)
    static let WheelRevolutionDataPresent       = MeasurementFlags(rawValue: 1 << 4)
    static let CrankRevolutionDataPresent       = MeasurementFlags(rawValue: 1 << 5)
    static let ExtremeForceMagnitudesPresent    = MeasurementFlags(rawValue: 1 << 6)
    static let ExtremeTorqueMagnitudesPresent   = MeasurementFlags(rawValue: 1 << 7)
    static let ExtremeAnglesPresent             = MeasurementFlags(rawValue: 1 << 8)
    static let TopDeadSpotAnglePresent          = MeasurementFlags(rawValue: 1 << 9)
    static let BottomDeadSpotAnglePresent       = MeasurementFlags(rawValue: 1 << 10)
    static let AccumulatedEnergyPresent         = MeasurementFlags(rawValue: 1 << 11)
    static let OffsetCompensationIndicator      = MeasurementFlags(rawValue: 1 << 12)
}



