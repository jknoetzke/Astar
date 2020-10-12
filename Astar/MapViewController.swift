//
//  MapViewController.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-10.
//

import Foundation
import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, LocationDelegate {
    
    
    
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    private var currentRegion: MKCoordinateRegion!
    
    var locationManager: LocationManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.setUserTrackingMode(.follow, animated:true)
        mapView.delegate = self
        mapView.userTrackingMode = .follow
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager!.locationDelegate = self
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        return renderer
    }
    
    func updateCurrentLocation(newLocation: CLLocation) {
        print("updateCurrentLocation")
        currentRegion = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(currentRegion, animated: true)
    }
    
    func updateMap(newLocation: CLLocation, lastLocation: CLLocation) {
        let coordinates = [lastLocation.coordinate, newLocation.coordinate]
        mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
    }
    
    func didNewLocationData(_ sender: LocationManager, newLocation: CLLocation, oldLocation: CLLocation) {
        updateMap(newLocation: newLocation, lastLocation: oldLocation)
        updateCurrentLocation(newLocation: newLocation)
    }
    
    
    
    
}
