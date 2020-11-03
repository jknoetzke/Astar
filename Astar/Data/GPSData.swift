//
//  GPSData.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-06.
//

import Foundation
import CoreLocation

public class GPSData {
 
    var speed = 0.0
    var altitude = 0.0
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var location: CLLocationCoordinate2D?
    var lastLocation: CLLocation?
    var currentLocation: CLLocation?
}
