//
//  RunRecord.swift
//  fm100
//
//  Created by Leonid Angarov on 20/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import SwiftyJSON

class RunRecord: Replyable {
    var id:Int = 0
    var create_date:NSDate = NSDate()
    var distance: Double = 0.0
    var time: Double = 0.0
    
    init () {
    }
    
    init (time:Double, distance:Double) {
        self.time = time
        self.distance = distance
    }
    
    init (id:Int, create_date:NSDate, time:Double, distance:Double) {
        self.id = id
        self.create_date = create_date
        self.time = time
        self.distance = distance
    }
}
