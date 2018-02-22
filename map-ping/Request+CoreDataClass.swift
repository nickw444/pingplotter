//
//  Request+CoreDataClass.swift
//  map-ping
//
//  Created by Nicholas Whyte on 25/2/18.
//  Copyright © 2018 Nicholas Whyte. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Request)
public class Request: NSManagedObject {
    func serialize() -> NSDictionary {
        let formatter = ISO8601DateFormatter()
        
        var recvTimeString: String? = nil
        if (self.recvTime != nil) {
            recvTimeString = formatter.string(from: self.recvTime! as Date)
        }
        return [
            "latency": self.latency,
            "recvLat": self.recvLat,
            "recvLong": self.recvLong,
            "recvSignal": self.recvSignal,
            "recvTechnology": self.recvTechnology as Any,
            "recvTime": recvTimeString as Any,
            "sendLat": self.sendLat,
            "sendLong": self.sendLong,
            "sendSignal": self.sendSignal,
            "sendTechnology": self.sendTechnology as Any,
            "sendTime": formatter.string(from: self.sendTime! as Date),
            "seqId": self.seqId,
            "timeout": self.timeout
        ]
    }
}
