//
//  ActivityFeedHostingController.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-23.
//

import Foundation
import SwiftUI
import UIKit
import Combine

/*
 class ActivityFeedHostingController: UIHostingController<ContentView> {
 required init?(coder aDecoder: NSCoder) {
 super.init(coder: aDecoder, rootView: ContentView())
 }
 }
 */


class ActivityFeedHostingController: UIViewController {
    
    private var cancellable: AnyCancellable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let coreDataService = CoreDataServices.sharedCoreDataService
        coreDataService.retrieveAllRideStats()
        
        let swiftUIView: some View = ContentView(coreDataService: coreDataService)
        let hostingController = UIHostingController(rootView: swiftUIView)
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
        
        self.cancellable = coreDataService.$rideMetrics.sink { rideMetrics in
            print(rideMetrics.count)
            
        }
    }
}

