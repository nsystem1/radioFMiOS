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

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let str = defaults.stringForKey("keySlugs")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
    }
}
