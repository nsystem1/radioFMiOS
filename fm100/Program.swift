//
//
//  fm100
//
//  Created by Leonid Angarov on 06/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import SwiftyXMLParser

class Program : Replyable  {
    var name: String = ""
    var desc: String = ""
    var day: String = ""
    var start: String = ""
    var end: String = ""
    var author: String = ""
    var image: String = ""
    
    init(){
        
    }
    
    init( post: XML.Accessor ) {
        self.parseItem(post)
    }
    
    func parseItem(post: XML.Accessor) -> () {
        self.name = post["ProgramName"].text!
        self.desc = post["ProgramDesc"].text!
        self.day = post["ProgramDay"].text!
        self.start = post["ProgramStartHoure"].text!
        self.end = post["ProgramEndHoure"].text!
        self.author = post["ProgramAutor"].text!
        
        if( post["ProgramImg"].text != nil  ) {
            self.image = post["ProgramImg"].text!
        }
    }
}