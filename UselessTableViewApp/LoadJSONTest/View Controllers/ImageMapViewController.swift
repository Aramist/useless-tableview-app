//
//  ImageMapViewController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/16/21.
//

import UIKit
import MapKit

class ImageMapViewController: UIViewController {
    
    
    @IBOutlet weak var imageMap: MKMapView!
    var delegate: ImageMapViewControllerDelegate?
    var locationManager: CLLocationManager?
    
    // Adding -5 allows the delegate's didChangeVisibleRegion to run on initialization
    var lastVicinityCheckTime = Date().addingTimeInterval(-5)
    var activeImageAnnotations: [ImageGroup] = []
    let maxAnnotations = 50
    
    
    deinit {
        delegate = nil
        imageMap.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.honeydew]
        navigationController?.navigationBar.backgroundColor = .imperialRed
        
        delegate = DataLoader()
        imageMap.delegate = self
        
        let testLocation = CLLocationCoordinate2DMake(40.731093, -73.999919)
        let testRegion = MKCoordinateRegion(
            center: testLocation,
            latitudinalMeters: 300,
            longitudinalMeters: 300)
        imageMap.setRegion(testRegion, animated: true)
        imageMap.register(
            LightweightImageAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: LightweightImageAnnotationView.reuseID)
        
        locationManager = CLLocationManager()
        guard let locationManager = locationManager,
              CLLocationManager.significantLocationChangeMonitoringAvailable()
        else {
            return
        }
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapViewDidChangeVisibleRegion(imageMap)
    }
}


extension ImageMapViewController: CLLocationManagerDelegate {
    /// Recomputes nearby images and presents annotations for them
    //    func locationManager(_ manager: CLLocationManager,
    //                         didUpdateLocations locations: [CLLocation]) {
    //        print("Location manager")
    //        guard let recentLocation = locations.last else {return}
    //
    //        let region = MKCoordinateRegion(center: recentLocation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
    //        imageMap.setRegion(region, animated: true)
    //        reloadAnnotations()
    //    }
}


//MARK: Delegate protocol
protocol ImageMapViewControllerDelegate {
    func imageMap(_ mapView: ImageMapViewController,
                  annotationsForRegion region: MKCoordinateRegion,
                  withPriorAnnotations prior: [ImageGroup]
    ) -> (newAnnotations: [ImageGroup], staleAnnotations: [ImageGroup])
}
