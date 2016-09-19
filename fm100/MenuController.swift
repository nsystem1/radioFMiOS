//
//  MenuController.swift
//  fm100
//
//  Created by Leonid Angarov on 07/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import UIKit


class MenuController: UITableViewController {
    var stations:[Station] = [Station]()
    
    @IBAction func clickFB(sender: AnyObject) {
        let application = UIApplication.sharedApplication()
        if application.canOpenURL(NSURL(string: "fb://profile/158664457479014")!) {
            application.openURL(NSURL(string: "fb://profile/158664457479014")!)
        } else {
            application.openURL(NSURL(string: "https://www.facebook.com/100FMRADIOS/")!)
        }
    }
    @IBAction func clickInst(sender: AnyObject) {
        let application = UIApplication.sharedApplication()
        if application.canOpenURL(NSURL(string: "instagram://user?username=radios_100fm")!) {
            application.openURL(NSURL(string: "instagram://user?username=radios_100fm"      )!)
        } else {
            application.openURL(NSURL(string: "https://www.instagram.com/radios_100fm/")!)
        }
    }
    @IBAction func clickSafari(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.100fm.co.il/")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuController.methodOfReceivedNotification(_:)), name:"reloadStationsNotification", object: nil)
    }
    
    func methodOfReceivedNotification(notification: NSNotification){
        stations = FM100Api.shared.stations
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: <TableViewDataSource>
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return stations.count == 0 ? 2 : 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? stations.count : 1
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 100 : 50
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let index = indexPath.section * 100 + indexPath.row
        
        if index >= 100 && index < 200 {
            NSNotificationCenter.defaultCenter().postNotificationName("changeStationsNotification", object: index - 100)
            let del = UIApplication.sharedApplication().delegate as! AppDelegate
            del.toggleRightDrawer(self, animated: true)
        } else if ( index == 200 ) {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://digital.100fm.co.il/app/policy.pdf")!)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier( indexPath.section == 0 ? "menu0" : "menu1" )! as UITableViewCell
        
        if indexPath.section == 1 {
            cell.textLabel?.text = stations[indexPath.row].name
        }
        
        if indexPath.section == 2 {
            cell.textLabel?.text = "תקנון"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
}
