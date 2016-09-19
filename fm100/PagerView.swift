//
//  PagerView.swift
//  MaccabiTLV
//
//  Created by Leonid Angarov on 08/10/2015.
//  Copyright © 2015 GoUFO. All rights reserved.
//

import Foundation
import UIKit

class PagerView : UIScrollView {
    var queue:[UIViewController] = [UIViewController]();
        
    func addController( controller:UIViewController ) {
        controller.view.frame = CGRectMake(self.frame.size.width * CGFloat(queue.count), 0, self.frame.size.width, self.frame.size.height)
        controller.view.clipsToBounds = true
        self.addSubview(controller.view)
        
        queue.append(controller)
        
        self.scrollEnabled = true;
        self.contentSize = CGSizeMake(self.frame.size.width * CGFloat(queue.count), self.frame.size.height - 50);
    }
    
    func clearViews() {
        if queue.count > 0 {
            for index in 0...queue.count - 1 {
                self.queue[index].removeFromParentViewController()
            }
            self.queue.removeAll()
        }
    }
    
    func resizeAll() {
        resizeToSize(self.frame.size)
    }
    
    func reverse() {
        queue = queue.reverse()
        resizeAll()
    }
    
    func resizeToSize(newSize: CGSize) {
        if queue.count > 0 {
            for index in 0...queue.count - 1 {
                if self.queue[index] is UITableViewController {
                    let table:UITableViewController = self.queue[index] as! UITableViewController
                    table.view.frame = CGRectMake(newSize.width * CGFloat(index), 0, newSize.width, newSize.height)
                    table.tableView.reloadData()
                } else {
                    let table:UIViewController = self.queue[index] 
                    table.view.frame = CGRectMake(newSize.width * CGFloat(index), 0, newSize.width, newSize.height)
                }
            }
            self.contentSize = CGSizeMake(newSize.width * CGFloat(queue.count), newSize.height - 50);
        }
    }
}