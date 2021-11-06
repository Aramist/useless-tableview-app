//
//  Chapter+CoreDataProperties.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/6/21.
//
//

import Foundation
import CoreData


extension Chapter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Chapter> {
        return NSFetchRequest<Chapter>(entityName: "Chapter")
    }

    @NSManaged public var chapterNumber: Int32
    @NSManaged public var contentURL: String?
    @NSManaged public var parentManga: Manga?

}

extension Chapter : Identifiable {

}
