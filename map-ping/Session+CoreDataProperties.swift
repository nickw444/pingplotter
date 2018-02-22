//
//  Session+CoreDataProperties.swift
//  map-ping
//
//  Created by Nicholas Whyte on 25/2/18.
//  Copyright © 2018 Nicholas Whyte. All rights reserved.
//
//

import Foundation
import CoreData


extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var device: String?
    @NSManaged public var network: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var requests: NSSet?

}

// MARK: Generated accessors for requests
extension Session {

    @objc(addRequestsObject:)
    @NSManaged public func addToRequests(_ value: Request)

    @objc(removeRequestsObject:)
    @NSManaged public func removeFromRequests(_ value: Request)

    @objc(addRequests:)
    @NSManaged public func addToRequests(_ values: NSSet)

    @objc(removeRequests:)
    @NSManaged public func removeFromRequests(_ values: NSSet)

}
