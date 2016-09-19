//
//  VideoYuoTube.swift
//  fm100
//
//  Created by Leonid Angarov on 06/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import SwiftyJSON

class VideoYouTube : Replyable  {
    var id: String = ""
    var title: String = ""
    var thumbnail: String = ""
    var published: NSDate = NSDate()
    
    init(){
        
    }
    
    init( post: JSON ) {
        self.parseItem(post)
    }
    
    init( id: String, title:String, thumbnail:String ) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
    }
    
    func parseItem(post: JSON) -> () {
        self.id = post["id"].stringValue //.asString ?? ""
        self.title = post["title"].stringValue //.asString ?? ""
        self.thumbnail = post["thumbnail"].stringValue //.asString ?? ""
        
        let date = post["published"].stringValue //.asString ?? ""
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.published = formatter.dateFromString(date)!
    }
}
