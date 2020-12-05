//
//  BluetoothDelegate.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-02.
//

import Foundation

protocol BluetoothDelegate {
    
    func didNewBLEUpdate(_ sender: DeviceManager, ble: BluetoothData)

}
