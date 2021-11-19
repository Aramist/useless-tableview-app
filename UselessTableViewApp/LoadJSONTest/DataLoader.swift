//
//  DataLoader.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/16/21.
//

import CoreData
import MapKit
import UIKit


class DataLoader {
    
    struct HistoricalImageJSON: Codable{
        var thumb_url: String  // Thumbnail, useful for map view
        var image_url: String  // Full image, useful for detail view
        var date: String  // The year the photo was taken
        var text: String?  // A description of the image
        var folder: String  // Seems to contain the intersection at which the photo was taken
        var id: String // The id of the image in the NYPL database
        var latitude: Float
        var longitude: Float
    }
    
    enum DatabaseError: Error {
        case failedToOpenFile
        case invalidJSON
        case invalidCoreDataContext
    }
    
    
    let jsonDataFileName = "historical_images_compact"
    var context: NSManagedObjectContext
    
    
    init? (){
        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else {return nil}
        context = appDelegate.persistentContainer.viewContext
        
        // If there is not yet a CoreData store for the JSON dataset...
        let entityCount = try? context.count(for: HistoricalImage.fetchRequest())
        if entityCount == 0 {
            // Then load the data in using a private context in a background thread
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.parent = context
            privateContext.perform {
                do {
                    try self.loadJSONDatabase(withContext: privateContext)
                    do {
                        try self.context.save()
                    }
                    catch {
                        print("Failed to save main CD context")
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    
    fileprivate func fetchImages(inRange coordinateRange: [(Float, Float)], withContext context: NSManagedObjectContext) throws -> [HistoricalImage]?{
        let request = HistoricalImage.fetchRequest()
        request.fetchLimit = 5
        let predicate = NSPredicate(
            format: "(%K >= %@) && (%K <= %@) && (%K >= %@) && (%K <= %@)",
            argumentArray: [
                #keyPath(HistoricalImage.latitude), coordinateRange[0].0,
                #keyPath(HistoricalImage.latitude), coordinateRange[1].0,
                #keyPath(HistoricalImage.longitude), coordinateRange[0].1,
                #keyPath(HistoricalImage.longitude), coordinateRange[1].1
            ]
        )
        request.predicate = predicate
        
        request.propertiesToFetch = ["photoID", "latitude", "longitude", "thumbnailURL"]
        
        do {
            let nearbyImages = try context.fetch(request)
            return nearbyImages
        }
        catch {
            print(error)
            return nil
        }
    }

    
    /// Loads the local image database JSON file and uses it to populate
    /// the table view's data source, imageDatabase
    fileprivate func loadJSONDatabase(withContext privateContext: NSManagedObjectContext) throws {
        // TODO: learn what the inDirectory: argument actually does
        if let jsonPath = Bundle.main.path(forResource: jsonDataFileName, ofType: "json") {
            do {
                let jsonData = try String(contentsOfFile: jsonPath).data(using: .utf8)
                guard let jsonData = jsonData else {
                    throw DatabaseError.failedToOpenFile
                }
                
                let jsonImageDataset = try JSONDecoder().decode([HistoricalImageJSON].self, from: jsonData)
                // Keep references alive until they are saved to the context
                // Actually, is this necessary? The context is passed into the initializer
                var referenceCache: [HistoricalImage] = []
                for jsonImageData in jsonImageDataset {
                    let imageCDObject = HistoricalImage(from: jsonImageData, withContext: privateContext)
                    referenceCache.append(imageCDObject)
                }
                try privateContext.save()
            }
            // TODO: Diversify error responses
            catch DecodingError.dataCorrupted(_), DecodingError.keyNotFound(_, _), DecodingError.typeMismatch(_, _), DecodingError.valueNotFound(_, _){
                throw DatabaseError.invalidJSON
            }
            catch {
                throw DatabaseError.failedToOpenFile
            }
        }
    }
}


extension DataLoader: ImageMapViewControllerDelegate {
    func imageMap(_ mapView: ImageMapViewController, annotationsForRegion region: MKCoordinateRegion, withPriorAnnotations prior: [HistoricalImage]) -> (newAnnotations: [HistoricalImage], staleAnnotations: [HistoricalImage]) {
        let coordRange = [
            (Float(region.center.latitude - 1e-3), Float(region.center.longitude - 1e-3)),
            (Float(region.center.latitude + 1e-3), Float(region.center.longitude + 1e-3))
        ]
        
        let ids = prior.map { (image) -> String in
            return image.photoID ?? ""
        }
        
        let results = try? fetchImages(inRange: coordRange, withContext: context)
        guard let results = results else {return (newAnnotations: [], staleAnnotations: prior)}
        let resultIds = results.map { (image) -> String in
            return image.photoID ?? ""
        }
        
        // All images in results whose id was not in prior annotations
        let newImages = results.filter {
            guard let id = $0.photoID else {return false}
            return !ids.contains(id)
        }
        
        // All images in prior annotations whose id did not appear in results
        let staleIds = prior.filter {
            guard let id = $0.photoID else {return false}
            return !resultIds.contains(id)
        }
        
        return (newAnnotations: newImages, staleAnnotations: staleIds)
    }
}
