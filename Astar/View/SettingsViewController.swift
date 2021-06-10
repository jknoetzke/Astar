//
//  DeviceViewController.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-08.
//

import Foundation
import UIKit
import Security

let METRIC_ROW = 1
let STRAVA_ROW = 4
let CYCLING_ANALYTICS_ROW = 5

let SETTINGS_SECTION = 0
let UPLOADS_SECTION = 1
let DEVICES_SECTION = 2

class SettingsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, BluetoothDelegate {
    
    @IBOutlet weak var deviceTableView: UITableView!
    
    var deviceManager:DeviceManager?
    
    var settings: [Settings] = [ Settings(name: "Metric/Imperial", id: "1", checked: false, tag: 1),
                                 Settings(name: "FTP", id: "2", tag: 2, input: "240"),
                                 Settings(name: "Modify Layout", id: "3", tag: 3)]


    var uploads: [Settings] = [ Settings(name: "Strava", id: "4", checked: false, tag: 4),
                                Settings(name: "Cycling Analytics", id: "5", checked: false, tag: 5)]
    
    var devices: [Settings] = []
    var allSettings: [Settings] = []
    
    
    func didNewBLEUpdate(_ sender: DeviceManager, ble: BluetoothData) {
        let device = Settings(name: ble.name!, id: ble.id!, checked: false, tag: devices.count + 1 + settings.count + uploads.count)

        if devices.firstIndex(where: {$0.id == device.id}) == nil {
            devices.append(device)
            allSettings.append(device)
            //deviceTableView.reloadData()
            deviceTableView.reloadSections(IndexSet(integer: DEVICES_SECTION), with: .automatic)
       }

    }
    
    private func registerTableViewCells() {
        let textFieldCell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        deviceTableView.register(textFieldCell, forCellReuseIdentifier: "CustomTableViewCell")
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTableView.dataSource = self
        deviceTableView.delegate = self
        
        
        deviceTableView.allowsSelection = true
        deviceTableView.isUserInteractionEnabled = true
        
        registerTableViewCells()
        deviceManager = DeviceManager.deviceManagerInstance
        deviceManager?.bleDelegate = self
        
        allSettings = settings + uploads
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap)
        
        deviceManager?.stopScanning()
        deviceManager?.startScanning(fullScan: true)
    }
    
    @objc func rowSelected()
    {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Restart with the new selected devices.
        
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
            label.text = "Preferences"
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
            switchTag = settings[indexPath.row].tag
            if switchTag == 2 {
                if let customCell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell") as? CustomTableViewCell {
                    return customCell
                }
            } else if switchTag == 3 {
                cell.textLabel?.text =  settings[indexPath.row].name
                return cell
            }
            
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
    
    func storeCyclingAnalyticsCreds(checked: Bool, toggle: UISwitch) {
        
        if checked {
            let alert = UIAlertController(title: "Enter your credentials", message: "Please enter your user name and password for Cycling Analytics", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "User"
            }
            
            alert.addTextField { (textFieldPass) in
                textFieldPass.placeholder = "Password"
                textFieldPass.isSecureTextEntry = true
            }
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
                print("User Canceled")
                toggle.setOn(false, animated: true)
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: "cycling_analytics")
            }))
            
            alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak alert] (_) in
                let txtUserName = alert?.textFields![0]
                let txtPassword = alert?.textFields![1]
                print("Text field: \(String(describing: txtUserName!.text))")
                print("Text field: \(String(describing: txtPassword!.text))")
                let userName = txtUserName!.text
                let password = txtPassword!.text
                
                let defaults = UserDefaults.standard
                defaults.setValue(userName, forKey: "cycling_analytics_username")
                defaults.setValue(password, forKey: "cycling_analytics_password")
                
                
                
            }))
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "cycling_analytics_username")
            defaults.removeObject(forKey: "cycling_analytics_password")
        }
        
    }
    
    @objc func switchChanged(_ sender : UISwitch!){
        
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        print("Switch Tg: \(sender.tag)")
        
        let defaults = UserDefaults.standard
        let switchState = sender.isOn
        let setting = allSettings[sender.tag-1]

        switch(sender.tag) {
        case METRIC_ROW :
            defaults.set(switchState, forKey: "metric")
            let viewController = self.tabBarController!.viewControllers![1] as! ViewController
            viewController.imperialFlag = sender.isOn
            break
        case STRAVA_ROW :
            defaults.set(switchState, forKey: "strava")
            if switchState {
                let strava = StravaManager()
                strava.authenticate()
            } else {
                defaults.removeObject(forKey: "strava_code")
            }
            break
        case CYCLING_ANALYTICS_ROW:
            storeCyclingAnalyticsCreds(checked: switchState, toggle: sender)
            defaults.set(switchState, forKey: "cycling_analytics")
            break
        default:
            deviceManager!.saveDevice(deviceID: setting.id, state: switchState)
            let viewController = self.tabBarController!.viewControllers![1] as! ViewController // or whatever tab index you're trying to access
            viewController.startScanning = true
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 2 {
            performSegue(withIdentifier: "RecordEditorSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordEditorSegue" {
            // Setup new view controller
        }
    }
    
}

