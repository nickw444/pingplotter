//
//  Request+CoreDataProperties.swift
//  map-ping
//
//  Created by Nicholas Whyte on 25/2/18.
//  Copyright © 2018 Nicholas Whyte. All rights reserved.
//
//

import Foundation
import CoreData


extension Request {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Request> {
        return NSFetchRequest<Request>(entityName: "Request")
    }

    @NSManaged public var seqId: Int32
    @NSManaged public var sendTime: NSDate?
    @NSManaged public var sendLat: Double
    @NSManaged public var sendLong: Double
    @NSManaged public var recvLat: Double
    @NSManaged public var recvLong: Double
    @NSManaged public var recvTime: NSDate?
    @NSManaged public var latency: Double
    @NSManaged public var timeout: Bool
    @NSManaged public var sendTechnology: String?
    @NSManaged public var recvTechnology: String?
    @NSManaged public var sendSignal: Int16
    @NSManaged public var recvSignal: Int16
    @NSManaged public var session: Session?

}
