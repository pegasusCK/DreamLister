//
//  Item+CoreDataClass.swift
//  DreamLister
//
//  Created by Chihkao Yu on 6/8/17.
//  Copyright © 2017 Chihkao Yu. All rights reserved.
//

import Foundation
import CoreData


public class Item: NSManagedObject {
    
    //when item is created from entity, then perform this function
    public override func awakeFromInsert() {
        
        super.awakeFromInsert()
        self.created = NSDate() //assign current date (created date) to created attribute
    }
}
