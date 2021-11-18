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
    let annotationViewReuseIdentifier = "historicalImageAnnotation"
    var delegate: ImageMapViewControllerDelegate?
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = DataLoader()
        imageMap.delegate = self
        let testLocation = CLLocationCoordinate2DMake(40.731093, -73.999919)
        let testRegion = MKCoordinateRegion(center: testLocation, latitudinalMeters: 300, longitudinalMeters: 300)
        imageMap.setRegion(testRegion, animated: true)
        imageMap.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: annotationViewReuseIdentifier)
        
        locationManager = CLLocationManager()
        guard let locationManager = locationManager,
              CLLocationManager.significantLocationChangeMonitoringAvailable()
        else {return}
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    deinit {
        // According to this blog post: https://blog.kulman.sk/using-custom-annotation-views-in-mkmapview/
        // Setting the delegate to nil on deinit avoids a certain bug
        imageMap.delegate = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadAnnotations()
    }
    
    fileprivate func reloadAnnotations() {
        if let annotations = delegate?.imageMap(self, annotationsForRegion: imageMap.region) {
            imageMap.removeAnnotations(imageMap.annotations)
            imageMap.addAnnotations(annotations)
        }
    }
    
}

extension ImageMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewReuseIdentifier)
        if annotationView == nil {
            annotationView = ImageAnnotationView(annotation: annotation, reuseIdentifier: annotationViewReuseIdentifier)
        }
        annotationView?.clusteringIdentifier = "HistoricalImages"
        
        return annotationView
    }
    
//    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
//        let cluster = MKClusterAnnotation(memberAnnotations: memberAnnotations)
//        return cluster
//    }
}

extension ImageMapViewController: CLLocationManagerDelegate {
    /// Recomputes nearby images and presents annotations for them
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        print("Location manager")
        guard let recentLocation = locations.last else {return}
        
        let region = MKCoordinateRegion(center: recentLocation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        imageMap.setRegion(region, animated: true)
        reloadAnnotations()
    }
}

protocol ImageMapViewControllerDelegate {
    func imageMap(_ imageMap: ImageMapViewController, annotationsForRegion region: MKCoordinateRegion) -> [HistoricalImage]
}
