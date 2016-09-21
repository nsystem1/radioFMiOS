//
//  Station.swift
//  fm100
//
//  Created by Leonid Angarov on 06/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Station : Replyable  {
    var name: String = ""
    var audio: String = ""
    var info: String = ""
    var slug: String = ""
    var logo: String = ""
    var cover: String = ""
    var description: String = ""
    var color: UIColor = UIColor(CGColor: UIColor.yellowColor().CGColor)
    
    init(){
        
    }
    
    init( post: JSON ) {
        self.parseItem(post)
    }
    
    func parseItem(post: JSON) -> () {
        self.name = post["name"].stringValue //.asString ?? ""
        self.audio = post["audio"].stringValue //.asString ?? ""
        self.info = post["info"].stringValue //.asString ?? ""
        self.slug = post["slug"].stringValue //.asString ?? ""
        self.logo = post["logo"].stringValue //.asString ?? ""
        self.cover = post["cover"].stringValue //.asString ?? ""
        self.description = post["description"].stringValue //.asString ?? ""
        
        self.color = hexStringToUIColor(post["color"].stringValue)
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
