//
//  HistoricalImage+CoreDataProperties.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/20/21.
//
//

import Foundation
import CoreData


extension HistoricalImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoricalImage> {
        return NSFetchRequest<HistoricalImage>(entityName: "HistoricalImage")
    }

    @NSManaged public var date: String?
    @NSManaged public var imageHeight: Int32
    @NSManaged public var imageWidth: Int32
    @NSManaged public var intersection: String?
    @NSManaged public var photoDescription: String?
    @NSManaged public var photoID: String?
    @NSManaged public var photoURL: String?
    @NSManaged public var thumbnailURL: String?
    @NSManaged public var parentGroup: ImageGroup?
}

extension HistoricalImage : Identifiable {

}
