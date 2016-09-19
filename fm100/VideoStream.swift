//
//  Video.swift
//  fm100
//
//  Created by Leonid Angarov on 06/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import SwiftyJSON

class VideoStream : Replyable  {
    var server: String = ""
    var stream: String = ""
    var info: String = ""
    var slug: String = ""
    var logo: String = ""
    
    init(){
        
    }
    
    init( post: JSON ) {
        self.parseItem(post)
    }
    
    func parseItem(post: JSON) -> () {
        self.server = post["server"].stringValue //.asString ?? ""
        self.stream = post["stream"].stringValue //.asString ?? ""
    }
}
