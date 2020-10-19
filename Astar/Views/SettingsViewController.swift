//
//  DeviceViewController.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-08.
//

import Foundation
import UIKit


class SettingsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    @IBOutlet weak var deviceTableView: UITableView!
    
    
    var devices: [Devices] = [ Devices(name: "Quarq", id: "1801", description: "Cinqo Power Meter"),
                               Devices(name: "4iiii Power Meter", id: "1101", description: "4iii Crank based power meter"),
                               Devices(name: "Wahoo HRM", id: "1101", description: "BLE Heart Rate Monitor")]
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        
        cell.textLabel?.text =  devices[indexPath.row].name
      //  cell.
        
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTableView.dataSource = self
        deviceTableView.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
}

