//
//  ImageGroup+CoreDataClass.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/20/21.
//
//

import Foundation
import CoreData
import MapKit

@objc(ImageGroup)
public class ImageGroup: NSManagedObject {
    
    convenience init(from jsonObject: DataLoader.JSONHistoricalImageGroup, withContext context: NSManagedObjectContext){
        self.init(context: context)
        self.latitude = jsonObject.latitude
        self.longitude = jsonObject.longitude
        
        jsonObject.photos.forEach { jsonPhoto in
            let image = HistoricalImage(from: jsonPhoto, withParent: self, withContext: context)
            self.addToImages(image)
        }
    }
    
    var imageArray: [HistoricalImage] {
        willAccessValue(forKey: "images")
        defer {didAccessValue(forKey: "images")}
        guard let imageSet = images as? Set<HistoricalImage>
        else {
            print("Failed to cast NSSet")
            return []
        }
        
        return imageSet.sorted {
            ($0.photoID ?? "") < ($1.photoID ?? "")
        }
    }
    
    var sampleImage: HistoricalImage? {
        willAccessValue(forKey: "images")
        defer {didAccessValue(forKey: "images")}
        guard let imageSet = images as? Set<HistoricalImage>
        else {
            print("Failed to cast NSSet")
            return nil
        }
        return imageSet.randomElement()
    }
    
    var imageCount: Int {
        images?.count ?? 0
    }

}

extension ImageGroup: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2DMake(Double(latitude), Double(longitude))
    }
    public var title: String? {
        nil
    }
    public var subtitle: String? {
        nil
    }
}
