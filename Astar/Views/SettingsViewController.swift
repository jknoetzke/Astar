//
//  DeviceViewController.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-08.
//

import Foundation
import UIKit

let METRIC_ROW = 1
let STRAVA_ROW = 2
let CYCLING_ANALYTICS_ROW = 3

let SETTINGS_SECTION = 0
let UPLOADS_SECTION = 1
let DEVICES_SECTION = 2

class SettingsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, BluetoothDelegate {
    
    @IBOutlet weak var deviceTableView: UITableView!
    
    var deviceManager:DeviceManager?
    
    var settings: [Settings] = [ Settings(name: "Metric/Imperial", id: "1", checked: false, tag: 1)]

    var uploads: [Settings] = [ Settings(name: "Strava", id: "2", checked: false, tag: 2),
                                Settings(name: "Cycling Analytics", id: "3", checked: false, tag: 3)]
    
    var devices: [Settings] = []
    var allSettings: [Settings] = []
    
    
    func didNewBLEUpdate(_ sender: DeviceManager, ble: BluetoothData) {
        let device = Settings(name: ble.name!, id: ble.id!, checked: false, tag: devices.count + 1 + settings.count + uploads.count)
        devices.append(device)
        allSettings.append(device)
        deviceTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTableView.dataSource = self
        deviceTableView.delegate = self
        deviceManager = DeviceManager.deviceManagerInstance
        deviceManager?.bleDelegate = self
        
        allSettings = settings + uploads
        
        deviceManager?.stopScanning()
        deviceManager?.startScanning(fullScan: true)
    }
    
    let SectionHeaderHeight: CGFloat = 25
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deviceManager?.stopScanning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case SETTINGS_SECTION:
            return settings.count
        case UPLOADS_SECTION:
            return uploads.count
        case DEVICES_SECTION:
            return devices.count
        default:
            break
        }
        
        return -1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        view.backgroundColor = UIColor.systemBlue
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: SectionHeaderHeight))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.white
        
        switch section {
        case SETTINGS_SECTION:
            label.text = "Metric"
            break
        case UPLOADS_SECTION:
            label.text = "Shared Data"
            break
        case DEVICES_SECTION:
            label.text = "Devices"
            break
        default:
            break
        }
        
        view.addSubview(label)
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        let defaults = UserDefaults.standard
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        var switchTag = 0
        var switchState = false

        switch indexPath.section {
        case SETTINGS_SECTION:
            cell.textLabel?.text =  settings[indexPath.row].name
            switchTag = settings[indexPath.row].tag
            switchState = defaults.bool(forKey: "metric")
            break
        case UPLOADS_SECTION:
            cell.textLabel?.text =  uploads[indexPath.row].name
            switchTag = uploads[indexPath.row].tag
            if indexPath.row == 0 {
                switchState = defaults.bool(forKey: "strava")
            } else if indexPath.row == 1 {
                switchState = defaults.bool(forKey: "cycling_analytics")
            }
            break
        case DEVICES_SECTION:
            let device = devices[indexPath.row]
            cell.textLabel?.text =  device.name
            switchTag = device.tag
            if deviceManager!.savedDevices.firstIndex(of: device.id) != nil {
                switchState = true
            } else {
                switchState = false
            }
            
        default:
            break
            
        }
        
        //here is programatically switch make to the table view
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(switchState, animated: true)
        switchView.tag = switchTag // for detect which row switch Changed
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    @objc func switchChanged(_ sender : UISwitch!){
        
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        print("Switch Tg: \(sender.tag)")
        
        let defaults = UserDefaults.standard
        let switchState = sender.isOn
        let setting = allSettings[sender.tag-1]
        
        print("Setting chosen: \(String(describing: setting.name))")

        switch(sender.tag) {
        case METRIC_ROW :
            defaults.set(switchState, forKey: "metric")
            break
        case STRAVA_ROW :
            defaults.set(switchState, forKey: "strava")
            break
        case CYCLING_ANALYTICS_ROW:
            defaults.set(switchState, forKey: "cycling_analytics")
            break
        default:
            deviceManager!.saveDevice(deviceID: setting.id, state: switchState)
            break
        }
    }
}

