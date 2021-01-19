//
//  RecordEditingHostingController.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-12-24.
//

import Foundation
import SwiftUI
import UIKit


class RecordEditingHostingController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recordEditor: some View = RecordEditor()
            
        let hostingController = UIHostingController(rootView: recordEditor)
        
        
        addChild(hostingController)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("dismissSwiftUI"), object: nil, queue: nil) { (_) in
            hostingController.dismiss(animated: true, completion: nil)
        }
        
        view.addSubview(hostingController.view)
        
        /// Setup the constraints to update the SwiftUI view boundaries.
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor),
            view.rightAnchor.constraint(equalTo: hostingController.view.rightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        /// Notify the hosting controller that it has been moved to the current view controller.
        hostingController.didMove(toParent: self)
        
        
        
    }
}

