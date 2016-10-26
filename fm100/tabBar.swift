//
//  tabBar.swift
//  fm100
//
//  Created by Leonid Angarov on 07/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import UIKit

class FMTabBar : UITabBarController {
    
    override func viewDidLoad() {
        for item in self.tabBar.items! {
            item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
            if let image = item.image {
                item.image = image.imageWithRenderingMode(.AlwaysOriginal)
            }
        }
        
        //self.selectedIndex = 2
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FMTabBar.ReceivedNotification(_:)), name:"RemotePushReceivedNotification", object: nil)
    }
    
    func ReceivedNotification(notification: NSNotification){
        self.selectedIndex = 0
    }
    
    override func viewWillLayoutSubviews() {
        var tabFrame:CGRect = self.tabBar.frame; //self.TabBar is IBOutlet of your TabBar
        tabFrame.size.height = 64;
        tabFrame.origin.y = self.view.frame.size.height - 64;
        self.tabBar.frame = tabFrame;
    }
}
