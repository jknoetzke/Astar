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
import Combine

class MapViewController: UIViewController, MKMapViewDelegate, LocationDelegate {
    
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    private var currentRegion: MKCoordinateRegion!
    private var coordinates =  [CLLocationCoordinate2D]()
    private var boundingRect = MKMapRect()
    
    var pinched = false
    private var pinchCounter = 0
    
    var locationManager = LocationManager.sharedLocationManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.setUserTrackingMode(.follow, animated:true)
        mapView.delegate = self
        initializeMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.locationDelegate = self
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
        if !pinched {
            if let first = mapView.overlays.first {
                boundingRect = mapView.overlays.reduce(first.boundingMapRect, {$0.union($1.boundingMapRect)})
                mapView.setVisibleMapRect(boundingRect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
            }
        }
        
    }
    
    func initializeMap() {
        
        var newLocation: CLLocation?
        var oldLocation: CLLocation?
        
        for cooridate in locationManager.coordinate2D {
            if oldLocation == nil {
                oldLocation = cooridate
            } else {
                oldLocation = newLocation
            }
            newLocation = cooridate
            updateMap(newLocation: newLocation!, lastLocation: oldLocation!)
        }
    }
    
    func updateMap(newLocation: CLLocation, lastLocation: CLLocation) {
        let newCoordinates = [lastLocation.coordinate, newLocation.coordinate]
        mapView.addOverlay(MKPolyline(coordinates: newCoordinates, count: 2))
    }
    
    func didNewLocationData(_ sender: LocationManager, newLocation: CLLocation, oldLocation: CLLocation) {
        pinchCounter = pinchCounter + 1
        
        if pinchCounter >= 10 && pinched == true {
            pinched = false
        }

        coordinates.append(newLocation.coordinate)
        updateMap(newLocation: newLocation, lastLocation: oldLocation)
        updateCurrentLocation(newLocation: newLocation)
    }
    
    @IBAction func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        pinched = true
        pinchCounter = 0
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        pinched = true
        pinchCounter = 0
    }
    
    func generateImageFromMap(ride: [PeripheralData], rideID: UUID) {
        
        let options = MKMapSnapshotter.Options()
        options.region = mapView.region
        
//        Working Size
//        options.size = CGSize(width: 180, height: 120)
        options.size = CGSize(width: 350, height: 375)
        
        options.showsBuildings = false
        
        if coordinates.count == 0 {
            
            let image = #imageLiteral(resourceName: "map")
            let coreDataServices = CoreDataServices.sharedCoreDataService
            coreDataServices.saveMetrics(ride: ride, mapImage: image, rideID: rideID)
            return
            
        }
        
        
        MKMapSnapshotter(options: options).start() { snapshot, error in
            guard let snapshot = snapshot else { return }
            let mapImage = snapshot.image

            let finalImage = UIGraphicsImageRenderer(size: mapImage.size).image { _ in
                
                // draw the map image
                mapImage.draw(at: .zero)
                // convert the `[CLLocationCoordinate2D]` into a `[CGPoint]`
                let points = self.coordinates.map { coordinate in
                    snapshot.point(for: coordinate)
                }
                
                // build a bezier path using that `[CGPoint]`
                let path = UIBezierPath()
                path.move(to: points[0])
                
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
                
                // stroke it
                path.lineWidth = 1
                UIColor.blue.setStroke()
                path.stroke()
            }
     
            let coreDataServices = CoreDataServices.sharedCoreDataService
            coreDataServices.saveMetrics(ride: ride, mapImage: finalImage, rideID: rideID)
        }
    }
}

extension Notification.Name {
    static let newRide = Notification.Name("new_ride")
}

struct NewRide {
    let title: String
}
