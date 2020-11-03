//
//  DeviceViewController.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-08.
//

import Foundation
import UIKit

let METRIC_ROW = 0
let STRAVA_ROW = 1
let CYCLING_ANALYTICS_ROW = 2

let SETTINGS_SECTION = 0
let UPLOADS_SECTION = 1
let DEVICES_SECTION = 2


class SettingsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var deviceTableView: UITableView!
    
    let SectionHeaderHeight: CGFloat = 25
    
    var devices: [Devices] = [ Devices(name: "Quarq", id: "1801", description: "Cinqo Power Meter"),
                               Devices(name: "4iiii Power Meter", id: "1101", description: "4iii Crank based power meter"),
                               Devices(name: "Wahoo HRM", id: "1101", description: "BLE Heart Rate Monitor")]
    
    var uploads: [Settings] = [ Settings(name: "Metric", checked: false),
                                 Settings(name: "Strava", checked: false),
                                 Settings(name: "Cycling Analytics", checked: false)]

    var settings: [Settings] = [ Settings(name: "Metric/Imperial", checked: false)]

    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        
        print(indexPath.row)
    
        switch indexPath.section {
        case SETTINGS_SECTION:
            cell.textLabel?.text =  settings[indexPath.row].name
            break
        case UPLOADS_SECTION:
            cell.textLabel?.text =  uploads[indexPath.row].name
            break
        case DEVICES_SECTION:
            cell.textLabel?.text =  devices[indexPath.row].name
        default:
            break

        }
        
        let defaults = UserDefaults.standard
        var switchState = false
        
        switch(indexPath.item) {
        case METRIC_ROW :
            switchState = defaults.bool(forKey: "metric")
            break
        case STRAVA_ROW :
            switchState = defaults.bool(forKey: "strava")
            break
        case CYCLING_ANALYTICS_ROW:
            switchState = defaults.bool(forKey: "cycling_analytics")
            break
        default:
            break
        }

        //here is programatically switch make to the table view
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(switchState, animated: true)
        switchView.tag = indexPath.row // for detect which row switch Changed
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
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
    
    @objc func switchChanged(_ sender : UISwitch!){
        
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        let defaults = UserDefaults.standard
        var switchState = sender.isOn
        
        switch(sender.tag) {
        case METRIC_ROW :
            defaults.set(switchState, forKey: "metric")
            break
        case STRAVA_ROW :
            switchState = defaults.bool(forKey: "strava")
            break
        case CYCLING_ANALYTICS_ROW:
            switchState = defaults.bool(forKey: "cycling_analytics")
            break
        default:
            break
        }
    }
}

