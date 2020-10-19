//
//  GPSDelegate.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-06.
//

import Foundation

protocol GPSDelegate {
    
    func didNewGPSData(_ sender: LocationManager, gps: GPSData)

}
