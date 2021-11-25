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
    
    
    struct JSONHistoricalImageGroup: Codable {
        var latitude: Float
        var longitude: Float
        var photos: [JSONHistoricalImage]
    }
    
    struct JSONHistoricalImage: Codable{
        var thumb_url: String  // Thumbnail, useful for map view
        var image_url: String  // Full image, useful for detail view
        var date: String?  // The year the photo was taken
        var text: String?  // A description of the image
        var folder: String?  // Seems to contain the intersection at which the photo was taken
        var id: String // The id of the image in the NYPL database
        var height: Int
        var width: Int
    }
    
    enum DatabaseError: Error {
        case failedToOpenFile
        case invalidJSON
        case invalidCoreDataContext
    }
    
    
    let jsonDataFileName = "historical_images_compact"
    var context: NSManagedObjectContext
    var dataSuccessfullyLoaded = false
    
    
    init? (){
        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else {return nil}
        context = appDelegate.persistentContainer.viewContext
        
        // If there is not yet a CoreData store for the JSON dataset...
        let entityCount = try? context.count(for: ImageGroup.fetchRequest())
        if entityCount == 0 {
            // Then load the data in using a private context in a background thread
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.parent = context
            privateContext.perform {
                do {
                    try self.loadJSONDatabase(withContext: privateContext)
                    do {
                        try self.context.save()
                        self.dataSuccessfullyLoaded = true
                    }
                    catch {
                        print("Failed to save main CD context")
                    }
                }
                catch {
                    print(error)
                }
            }
        } else {
            dataSuccessfullyLoaded = true
        }
    }
    
    
    fileprivate func fetchImages(inRange coordinateRange: [(Float, Float)], withContext context: NSManagedObjectContext) throws -> [ImageGroup]?{
        let request = ImageGroup.fetchRequest()
        let predicate = NSPredicate(
            format: "(%K >= %@) && (%K <= %@) && (%K >= %@) && (%K <= %@)",
            argumentArray: [
                #keyPath(ImageGroup.latitude), coordinateRange[0].0,
                #keyPath(ImageGroup.latitude), coordinateRange[1].0,
                #keyPath(ImageGroup.longitude), coordinateRange[0].1,
                #keyPath(ImageGroup.longitude), coordinateRange[1].1
            ]
        )
        request.predicate = predicate
        
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
                
                let jsonImageDataset = try JSONDecoder().decode([JSONHistoricalImageGroup].self, from: jsonData)
                
                var refs: [ImageGroup] = []
                for jsonImageData in jsonImageDataset {
                    let newGroup = ImageGroup(from: jsonImageData, withContext: privateContext)
                    refs.append(newGroup)
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
        } else {
            throw DatabaseError.failedToOpenFile
        }
    }
}


extension DataLoader: ImageMapViewControllerDelegate {
    func imageMap(_ mapView: ImageMapViewController, annotationsForRegion region: MKCoordinateRegion, withPriorAnnotations prior: [ImageGroup]) -> (newAnnotations: [ImageGroup], staleAnnotations: [ImageGroup]) {
        let coordRange = [
            (Float(region.center.latitude - 3e-3), Float(region.center.longitude - 3e-3)),
            (Float(region.center.latitude + 3e-3), Float(region.center.longitude + 3e-3))
        ]
        
        guard dataSuccessfullyLoaded else {
            return (newAnnotations: [], staleAnnotations: [])
        }
        
        guard let results = try? fetchImages(inRange: coordRange, withContext: context)
        else {
            return (newAnnotations: [], staleAnnotations: [])
        }
        
        let priorIdHashes = prior.map {
            $0.objectID.hashValue
        }
        let newImageGroups = results.filter {
            !priorIdHashes.contains($0.objectID.hashValue)
        }
        let staleAnnotations: [ImageGroup] = []
        
        return (newAnnotations: newImageGroups, staleAnnotations: staleAnnotations)
    }
}
