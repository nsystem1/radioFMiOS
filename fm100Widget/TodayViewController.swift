//
//  TodayViewController.swift
//  fm100Widget
//
//  Created by Leonid Angarov on 17/11/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import UIKit
import Foundation
import NotificationCenter
import Alamofire
import SwiftyJSON
import Kingfisher

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    
    let defaults = NSUserDefaults.init(suiteName: "group.fm100SharingGroup")
    
    var channels:[Channel] = []
    var slugs:[String] = []
    
    func reloadDate() {
        Alamofire.request(.GET, "http://digital.100fm.co.il/app/", parameters: [:]).responseJSON { response in
            if response.result.error != nil {
                return
            }
            if let data = response.result.value {
                let json = JSON(data)
                self.channels.removeAll()
                for (_, subJson) in json["stations"] {
                    let channel:Channel = Channel(post: subJson)
                    self.channels.append(channel)
                }
                self.updateButtons()
            }
        }
    }
    
    func updateButtons() {
        let buttons:[UIButton] = [btn1, btn2, btn3, btn4]
        
        slugs = ["100fm","hits","top40","workout"]
        let slugStr = defaults!.stringForKey("keySlugs")
        if( slugStr != nil ) {
            slugs = slugStr!.componentsSeparatedByString(",")
        }
        
        for index in 0..<slugs.count {
            for channel in channels {
                if( channel.slug == slugs[index] ) {
                    let btn:UIButton = buttons[index]
                    btn.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
                    btn.kf_setImageWithURL(NSURL(string: channel.logo)!, forState:UIControlState.Normal)
                    btn.accessibilityIdentifier = channel.slug
                }
            }
        }
    }
    
    @IBAction func clickOpenChannel(sender: AnyObject) {
        let btn:UIButton = sender as! UIButton
        
        let url:NSURL? = NSURL(string: "fm100://?slug=" + btn.accessibilityIdentifier!)
        self.extensionContext?.openURL(url!, completionHandler: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadDate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        updateButtons()
    }
}
