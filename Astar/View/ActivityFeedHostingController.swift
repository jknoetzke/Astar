//
//  ActivityFeedHostingController.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-23.
//

import Foundation
import SwiftUI
import UIKit


class ActivityFeedHostingController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let persistenceController = PersistenceController.shared
        
        let activityView: some View = ActivityView().environment(\.managedObjectContext, persistenceController.container.viewContext)
            
        let hostingController = UIHostingController(rootView: activityView)
        
        
        addChild(hostingController)
        
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

