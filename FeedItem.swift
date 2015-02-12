//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Marko Budal on 09/02/15.
//  Copyright (c) 2015 Marko Budal. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbNail: NSData
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var uniqueID: String
    @NSManaged var filtereed: NSNumber

}
