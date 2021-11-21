//
//  ImageGroup+CoreDataProperties.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/20/21.
//
//

import Foundation
import CoreData


extension ImageGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageGroup> {
        return NSFetchRequest<ImageGroup>(entityName: "ImageGroup")
    }

    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for images
extension ImageGroup {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: HistoricalImage)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: HistoricalImage)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

extension ImageGroup : Identifiable {

}
