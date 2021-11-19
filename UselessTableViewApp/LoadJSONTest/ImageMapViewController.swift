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
    
    override func viewDidAppear(_ animated: Bool) {
        reloadAnnotations()
    }
    
    fileprivate func reloadAnnotations() {
        guard let annotations = imageMap.annotations.filter {$0 is HistoricalImage} as? [HistoricalImage]
        else {
            return
        }
        
        let startTime = Date()
        if let annotationUpdate = delegate?.imageMap(self, annotationsForRegion: imageMap.region, withPriorAnnotations: annotations) {
//            imageMap.removeAnnotations(annotationUpdate.staleAnnotations)
            imageMap.addAnnotations(annotationUpdate.newAnnotations)
            print("Stale count: \(annotationUpdate.staleAnnotations.count),\tNew count: \(annotationUpdate.newAnnotations.count),\tRuntime: \(-startTime.timeIntervalSinceNow)")
        }
    }
    
}

//MARK: Conformance Extensions
extension ImageMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotationIsCustom(annotation) else {return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewReuseIdentifier)
        if annotationView == nil {
            annotationView = ImageAnnotationView(annotation: annotation, reuseIdentifier: annotationViewReuseIdentifier)
        }
        guard let annotationView = annotationView else {return nil}
        
        if annotation is HistoricalImage {
            annotationView.clusteringIdentifier = "HistoricalImages"
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated")
        reloadAnnotations()
    }
    
    //    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
    //        let cluster = MKClusterAnnotation(memberAnnotations: memberAnnotations)
    //        return cluster
    //    }
    
    /// Determines whether a given annotation is one of our implementations
    /// - Parameter annotation: annotation to test
    /// - Returns: True if annotation is HistoricalImage or cluster of HistoricalImage
    fileprivate func annotationIsCustom(_ annotation: MKAnnotation) -> Bool{
        let isHistoricalImage = annotation is HistoricalImage
        if (isHistoricalImage) {
            return true
        }
        
        guard let cluster = annotation as? MKClusterAnnotation else {return false}
        return cluster.memberAnnotations is [HistoricalImage]
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
    func imageMap(_ imageMap: ImageMapViewController, annotationsForRegion region: MKCoordinateRegion,  withPriorAnnotations prior: [HistoricalImage]) -> (newAnnotations: [HistoricalImage], staleAnnotations: [HistoricalImage])
}
