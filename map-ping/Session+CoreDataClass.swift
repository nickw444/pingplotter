//
//  Session+CoreDataClass.swift
//  map-ping
//
//  Created by Nicholas Whyte on 25/2/18.
//  Copyright © 2018 Nicholas Whyte. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Session)
public class Session: NSManagedObject {
    func serialize() -> NSDictionary {
        let formatter = ISO8601DateFormatter()
        
        let requests = self.requests!.allObjects as! [Request]
        let serializedRequests = requests.map { (r: Request) -> NSDictionary in
            return r.serialize()
        }
        return [
            "exportedAt": formatter.string(from: Date()),
            "date": formatter.string(from: self.date! as Date),
            "device": self.device as Any,
            "network": self.network as Any,
            "requests": serializedRequests,
        ]
    }
}
