//
//  HistoricalImage+CoreDataProperties.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/13/21.
//
//

import Foundation
import CoreData


extension HistoricalImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoricalImage> {
        return NSFetchRequest<HistoricalImage>(entityName: "HistoricalImage")
    }

    @NSManaged public var date: String?
    @NSManaged public var photoDescription: String?
    @NSManaged public var photoID: String?
    @NSManaged public var photoURL: String?
    @NSManaged public var thumbnailURL: String?
    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var intersection: String?

}

extension HistoricalImage : Identifiable {

}
