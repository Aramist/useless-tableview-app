//
//  HistoricalImage+CoreDataClass.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/11/21.
//
//

import Foundation
import CoreData
import MapKit

@objc(HistoricalImage)
public class HistoricalImage: NSManagedObject {
    
    var thumbnailImage: UIImage?
    var fullImage: UIImage?
    
    convenience init(from jsonObject: DataLoader.HistoricalImageJSON, withContext context: NSManagedObjectContext) {
        self.init(context: context)
        date = jsonObject.date
        photoDescription = jsonObject.text
        photoID = jsonObject.id
        photoURL = jsonObject.image_url
        thumbnailURL = jsonObject.thumb_url
        latitude = jsonObject.latitude
        longitude = jsonObject.longitude
        intersection = jsonObject.folder
        imageWidth = Int32(jsonObject.width)
        imageHeight = Int32(jsonObject.height)
    }
    
    
    func cacheThumbnailImage(completion: ((_ image: UIImage?, _ success: Bool) -> ())? ) {
        guard let thumbnailString = thumbnailURL,
              let thumbnailURL = URL(string: thumbnailString)
        else {
            completion?(nil, false)
            return
        }
        
        URLSession.shared.dataTask(with: thumbnailURL) { [weak self] (data, response, error) in
            if let data = data{
                guard let self = self,
                      let image = UIImage(data: data)
                else {return}
                
                self.thumbnailImage = image
                completion?(image, true)
            }
            completion?(nil, false)
        }.resume()
    }
    
    func cacheFullImage(completion: ((_ image: UIImage?, _ success: Bool) -> ())? ) {
        guard let imageURLString = photoURL,
              let imageURL = URL(string: imageURLString)
        else {
            completion?(nil, false)
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { [weak self] (data, response, error) in
            if let data = data{
                guard let self = self,
                      let image = UIImage(data: data)
                else {return}
                
                self.fullImage = image
                completion?(image, true)
            }
            completion?(nil, false)
        }.resume()
    }
}

extension HistoricalImage: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2DMake(Double(latitude), Double(longitude))
    }
    public var title: String? {
        intersection
    }
    public var subtitle: String? {
        date
    }
}
