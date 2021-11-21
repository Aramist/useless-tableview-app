//
//  HistoricalImage+CoreDataClass.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/20/21.
//
//

import CoreData
import UIKit

public class HistoricalImage: NSManagedObject {
    //TODO: Implement a static watchdog for the number of cached images to prevent it from going
    //TODO: above a certain amount. Implement a fileprivate function to decache images not recently
    //TODO: accessed
    var thumbnailImage: UIImage?
    var fullImage: UIImage?
    
    convenience init(from jsonObject: DataLoader.JSONHistoricalImage, withParent parent: ImageGroup, withContext context: NSManagedObjectContext) {
        self.init(context: context)
        date = jsonObject.date
        photoDescription = jsonObject.text
        photoID = jsonObject.id
        photoURL = jsonObject.image_url
        thumbnailURL = jsonObject.thumb_url
        intersection = jsonObject.folder
        imageWidth = Int32(jsonObject.width)
        imageHeight = Int32(jsonObject.height)
        parentGroup = parent
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
