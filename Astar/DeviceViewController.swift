//
//  DeviceViewController.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-08.
//

import Foundation
import UIKit


class DeviceViewController : UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var reusableCell: UITableViewCell!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        
        cell.textLabel?.text =  "This is a cell"
        
        return cell
    }
    
    
    @IBOutlet weak var deviceTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTableView.dataSource = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}

