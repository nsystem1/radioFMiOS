//
//  Channel.swift
//  fm100
//
//  Created by Leonid Angarov on 18/11/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Channel {
    var name: String = ""
    var slug: String = ""
    var logo: String = ""
    
    init(){
        
    }
    
    init( post: JSON ) {
        self.parseItem(post)
    }
    
    func parseItem(post: JSON) -> () {
        self.name = post["name"].stringValue
        self.slug = post["slug"].stringValue
        self.logo = post["logo"].stringValue
    }
}

