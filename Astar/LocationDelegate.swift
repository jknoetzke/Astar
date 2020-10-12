//
//  LocationDelegate.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-10.
//

import Foundation
import CoreLocation

protocol LocationDelegate {
    
    func didNewLocationData(_ sender: LocationManager, newLocation: CLLocation, oldLocation: CLLocation)

}
