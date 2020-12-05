//
//  RideDelegate.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-09-28.
//

import Foundation

protocol RideDelegate {
    
    func didNewRideData(_ sender: DeviceManager, ride: PeripheralData)

}
