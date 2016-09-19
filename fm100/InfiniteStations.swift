//
//  InfiniteScroll.swift
//  fm100
//
//  Created by Leonid Angarov on 23/08/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import UIKit

class InfiniteStations: UIView {
    var stations:[Station] = [Station]()
    
    var views:[UIButton] = [UIButton]()
    let imgh:CGFloat = 70
    let imgh2:CGFloat = 30
    
    var lastTouche:CGPoint = CGPoint()
    
    var pos:CGFloat = 0
    
    func setStations(stations:[Station]) {
        self.stations = stations;
        
        reloadData()
    }
    
    func reloadData() {
        for index in 0..<self.stations.count {
            let btn:UIButton = UIButton(frame: CGRectMake(0, CGFloat(index - 1) * imgh, self.frame.size.width, imgh))
            btn.accessibilityIdentifier = String(index)
            btn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
            btn.imageView?.clipsToBounds = true
            btn.kf_setImageWithURL(NSURL(string: self.stations[index].logo)!, forState:UIControlState.Normal)
            //btn.addTarget(self, action: #selector(StationsList.changeStaion(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            views.append(btn)
            self.addSubview(btn)
        }
        reloadLayout();
    }
    
    func reloadLayout() {
        if( self.views.count > 0 ) {
            for index in 0..<self.views.count {
                let img:UIButton = self.views[index]
                img.frame = CGRectMake(0, self.frame.size.height / 2 + CGFloat(index) * imgh - 0.5 * imgh + imgh2 * CGFloat(index) + 50 - pos, self.frame.size.width, imgh)
            }
        }
    }
}