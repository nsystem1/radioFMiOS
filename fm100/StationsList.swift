//
//  StationsData.swift
//  fm100
//
//  Created by Leonid Angarov on 06/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

protocol StationDelegate {
    func StationChanged(index:Int)
}

class StationsList : UIScrollView, UIScrollViewDelegate {
    var stations:[Station] = [Station]()
    
    @IBOutlet weak var arrow1: UIImageView!
    @IBOutlet weak var arrow2: UIImageView!
    
    var views:[UIButton] = [UIButton]()
    let imgh:CGFloat = 70
    let imgh2:CGFloat = 30
    var selected:Int = 0
    
    var topOffset: CGFloat = 0
    
    var delegateStation:StationDelegate! = nil
    
    func setStations(stations:[Station]) {
        self.stations = stations;
        
        self.decelerationRate = UIScrollViewDecelerationRateFast
        
        reloadData()
        reloadData()
        self.selected = self.stations.count
        self.scrollRectToVisible(CGRectMake(0, CGFloat(self.stations.count) * (self.imgh + self.imgh2) * 2, self.frame.size.width, self.frame.size.height), animated: false)
        
        self.layer.opacity = 0
        UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.layer.opacity = 1
            self.scrollRectToVisible(CGRectMake(0, CGFloat(self.stations.count) * (self.imgh + self.imgh2), self.frame.size.width, self.frame.size.height), animated: false)
        }) { finished in
            self.delegate = self
            
            let v:UIView = self.views[self.selected]
            self.arrow1.frame = CGRectMake(8, v.frame.origin.y + v.frame.height / 2,self.arrow1.frame.size.width, self.arrow1.frame.size.height)
            self.arrow2.frame = CGRectMake(self.frame.size.width - 20 - 8, self.arrow1.frame.origin.y, self.arrow2.frame.size.width, self.arrow2.frame.size.height)
            self.arrow1.hidden = false
            self.arrow2.hidden = false
            
            self.changeStation(0);
        }
        
        UIView.animateWithDuration(0.3, delay: 1.7, options: .CurveEaseInOut, animations: {
            self.drawStation(self.contentOffset.y)
        }) { finished in
        }
    }
    
    func changeStation(index:Int) {
        if( index == 0 && self.selected % self.stations.count == self.stations.count - 1 ) {
            self.selected += self.stations.count
        }
        if( self.selected % self.stations.count == 0 && index == self.stations.count - 1 ) {
            self.selected -= self.stations.count
        }
        self.selected = (selected - (selected % self.stations.count)) + index;
        
        scrollToTheSelectedCell()
    }
    
    func getNextStation() {
        self.selected += 1
        scrollToTheSelectedCell()
    }
    
    func getPrevStation() {
        self.selected -= 1
        scrollToTheSelectedCell()
    }
    
    func changeStaionClicked(object : UIButton) {
        self.changeStation( Int( object.accessibilityIdentifier! )! )
        self.delegateStation.StationChanged(self.selected % self.stations.count)
    }

    
    func reloadData() {
        for index in 0..<self.stations.count {
            let btn:UIButton = UIButton(frame: CGRectMake(0, CGFloat(index - 1) * imgh, self.frame.size.width, imgh))
            btn.accessibilityIdentifier = String(index)
            btn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
            btn.imageView?.clipsToBounds = true
            btn.contentMode = UIViewContentMode.ScaleAspectFit
            btn.clipsToBounds = true
            btn.kf_setImageWithURL(NSURL(string: self.stations[index].logo)!, forState:UIControlState.Normal)
            btn.addTarget(self, action: #selector(StationsList.changeStaionClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            views.append(btn)
            self.addSubview(btn)
        }
        self.contentSize = CGSize(width: self.frame.size.width, height: self.frame.size.height + CGFloat(self.views.count - 1) * (imgh + imgh2) )
        reloadLayout();
    }
    
    func reloadLayout() {
        if( self.views.count > 0 ) {
            for index in 0...self.views.count - 1 {
                let img:UIButton = self.views[index]
                img.frame = CGRectMake(0, self.frame.size.height / 2 + CGFloat(index) * (imgh + imgh2) - 0.5 * imgh + 50, self.frame.size.width, imgh)
            }
            self.contentSize = CGSize(width: self.frame.size.width, height: self.frame.size.height + CGFloat(self.views.count - 1) * (imgh + imgh2) )
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollToTheSelectedCell();
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if( !decelerate ) {
            scrollToTheSelectedCell();
        }
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        //scrollToTheSelectedCell();
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.delegateStation.StationChanged(self.selected % self.stations.count)
    }
    
    func scrollToTheSelectedCell() {
        self.scrollRectToVisible(CGRectMake(0, CGFloat(self.selected) * (self.imgh + imgh2), self.frame.size.width, self.frame.size.height), animated: true)
    }
    
    func drawStation(pos:CGFloat) {
        
        for i in 0...self.views.count - 1 {
            let btn:UIButton = self.views[i]
            var scale:CGFloat = cos( CGFloat(M_PI) * (pos - (imgh + imgh2) * CGFloat(i)) / self.frame.height)
            
            scale = scale * scale
            
            btn.layer.opacity = Float(scale)
            
            if scale < 0.2 {
                scale = 0.2
            }
            btn.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }
    
    func manageScrollSize() {
        let pos = self.contentOffset.y
        if( self.contentSize.height - self.frame.size.height * 2 < pos || pos < self.frame.size.height ) {
            for index in 0..<self.stations.count {
                let btn:UIButton = UIButton(frame: CGRectMake(0, CGFloat(index - 1) * imgh, self.frame.size.width, imgh))
                btn.accessibilityIdentifier = String(index)
                btn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                btn.imageView?.clipsToBounds = true
                btn.contentMode = UIViewContentMode.ScaleAspectFit
                btn.clipsToBounds = true
                btn.kf_setImageWithURL(NSURL(string: self.stations[index].logo)!, forState:UIControlState.Normal)
                btn.addTarget(self, action: #selector(StationsList.changeStaionClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                views.append(btn)
                
                self.addSubview(btn)
            }
            if pos < self.frame.size.height {
                self.selected += self.stations.count
                self.topOffset += CGFloat(self.stations.count) * (imgh + imgh2)
                self.contentOffset = CGPoint(x: 0, y: pos + topOffset)
            }
            self.reloadLayout()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        manageScrollSize();
        
        let pos = self.contentOffset.y
        
        var index:Int = Int(round(pos / (imgh + imgh2)));
        if( index < 0 ) {
            index = 0;
        }
        if( index >= self.views.count ) {
            index = self.views.count - 1;
        }
        drawStation(pos)
        
        if( self.selected != index ) {
            self.selected = index;
        }
        
        let v:UIView = self.views[self.selected]
        arrow1.frame = CGRectMake(8, v.frame.origin.y - pos + v.frame.height / 2,arrow1.frame.size.width, arrow1.frame.size.height)
        arrow2.frame = CGRectMake(self.frame.size.width - 20 - 8, arrow1.frame.origin.y, arrow2.frame.size.width, arrow2.frame.size.height)
    }
    
}
