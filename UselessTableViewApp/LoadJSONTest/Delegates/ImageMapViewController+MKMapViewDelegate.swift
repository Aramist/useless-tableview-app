//
//  ImageMapViewController+MKMapViewDelegate.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/20/21.
//

import UIKit
import MapKit


extension ImageMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is ImageGroup else {return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: LightweightImageAnnotationView.reuseID)
        if annotationView == nil {
            annotationView = LightweightImageAnnotationView(annotation: annotation, reuseIdentifier: LightweightImageAnnotationView.reuseID)
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        reloadAnnotations()
    }
    
    
    fileprivate func reloadAnnotations() {
        // This is necessary because the user location icon counts as an annotation
        guard let priorAnnotations = imageMap.annotations.filter({ $0 is ImageGroup })as? [ImageGroup]
        else {
            // No prior annotations
            return
        }
        
        // I think MapView is bad at removing annotations so I'm going to avoid doing
        // that whenever possible
        if let annotationUpdate = delegate?.imageMap(self, annotationsForRegion: imageMap.region, withPriorAnnotations: priorAnnotations) {
            imageMap.addAnnotations(annotationUpdate.newAnnotations)
        }
    }
    
    
    /// Have nearby image annotations popup and shrink while the map is scrolling
    /// - Parameter mapView: the map view
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        // Avoid calling annotations in MKMapRect too often
        guard lastVicinityCheckTime.timeIntervalSinceNow < -0.2 else {return}
        lastVicinityCheckTime = Date()
        
        let onScreenAnnotations = mapView.annotations(in: MKMapRectForCoordinateRegion(region: mapView.region))
        let closest = nearestImageGroups(fromSet: onScreenAnnotations, toPoint: mapView.centerCoordinate, limit: 5)
        let diff = annotationDifference(betweenPriorAnnotations: activeImageAnnotations, postAnnotations: closest)
        
        activeImageAnnotations.removeAll {
            diff.removedAnnotations.contains($0)
        }
        activeImageAnnotations.append(contentsOf: diff.addedAnnotations)
        
        diff.removedAnnotations.forEach {
            if let group = mapView.view(for: $0) as? LightweightImageAnnotationView {
                group.deactivate()
            }
        }
        diff.addedAnnotations.forEach {
            if let group = mapView.view(for: $0) as? LightweightImageAnnotationView {
                group.activate()
            }
        }
    }
    
    /// Taken from https://stackoverflow.com/questions/9270268/convert-mkcoordinateregion-to-mkmaprect
    func MKMapRectForCoordinateRegion(region:MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))

        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)
        
        return MKMapRect(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
    }
    
    func nearestImageGroups(fromSet annotations: Set<AnyHashable>, toPoint center: CLLocationCoordinate2D, limit: Int) -> [ImageGroup] {
        let center = MKMapPoint(center)
        let sortedAnnotations: [ImageGroup] = annotations.filter {
            $0 is ImageGroup
        }.map {
            return $0 as! ImageGroup
        }.sorted {
            MKMapPoint($0.coordinate).distance(to: center) < MKMapPoint($1.coordinate).distance(to: center)
        }
        
        if sortedAnnotations.count < limit {
            return sortedAnnotations
        }
        return Array(sortedAnnotations[0..<limit])
    }
    
    
    func annotationDifference(betweenPriorAnnotations prior: [ImageGroup], postAnnotations post: [ImageGroup]) -> (addedAnnotations: [ImageGroup], removedAnnotations: [ImageGroup]) {
   
        
        let priorIdHashes = prior.map {
            $0.objectID.hashValue
        }
        let postIdHashes = post.map {
            $0.objectID.hashValue
        }
        
        let newImageGroups = post.filter {
            !priorIdHashes.contains($0.objectID.hashValue)
        }
        let removedImageGroups = prior.filter {
            !postIdHashes.contains($0.objectID.hashValue)
        }
        
        
        return (addedAnnotations: newImageGroups, removedAnnotations: removedImageGroups)
    }
}
