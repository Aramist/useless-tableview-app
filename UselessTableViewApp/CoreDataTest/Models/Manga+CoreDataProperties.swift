//
//  Manga+CoreDataProperties.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/6/21.
//
//

import Foundation
import CoreData


extension Manga {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Manga> {
        return NSFetchRequest<Manga>(entityName: "Manga")
    }

    @NSManaged public var chapterCount: Int16
    @NSManaged public var name: String?
    @NSManaged public var synopsis: String?
    @NSManaged public var chapters: NSSet?

}

// MARK: Generated accessors for chapters
extension Manga {

    @objc(addChaptersObject:)
    @NSManaged public func addToChapters(_ value: Chapter)

    @objc(removeChaptersObject:)
    @NSManaged public func removeFromChapters(_ value: Chapter)

    @objc(addChapters:)
    @NSManaged public func addToChapters(_ values: NSSet)

    @objc(removeChapters:)
    @NSManaged public func removeFromChapters(_ values: NSSet)

}

extension Manga : Identifiable {

}
