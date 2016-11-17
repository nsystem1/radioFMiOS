//
//  TimeTableController.swift
//  fm100
//
//  Created by Leonid Angarov on 22/08/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import AVFoundation
import Alamofire
import SwiftyXMLParser
import FacebookShare

class TimeTableController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var loadingItems:Int = 0
    
    @IBOutlet weak var tableView:UITableView? = UITableView()
    
    var programs:[[Program]] = [[Program]]()
    var day:Int = 0
    var day_index:Int = 0
    
    var isDataLoaded:Bool = false
    
    @IBAction func toggleRightDrawer(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.toggleRightDrawer(sender, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let img = UIImageView(frame: CGRectMake(0, 0, 50, 20))
        img.image = UIImage(named: "fm1003")
        img.contentMode = UIViewContentMode.ScaleAspectFit
        self.navigationItem.titleView = img;
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "header"), forBarMetrics: .Default)
        
        self.tableView!.estimatedRowHeight = 200.0
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        
        reloadData()
    }
    
    func reloadData() {
        FM100Api.shared.getPrograms { (status) in
            if( status ) {
                self.programs = FM100Api.shared.programs
                self.isDataLoaded = true
                self.displayProgram()
            }
        }
    }
    
    func displayProgram() {
        if !isDataLoaded {
            return
        }
        
        let todayDate = NSDate()
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let myComponents = myCalendar?.components([.Weekday, .Hour], fromDate: todayDate)
        let hour = (myComponents?.hour)! * 100
        
        self.day = ( myComponents!.weekday + 6 ) % 7
        self.day_index = 0
        
        self.tableView!.reloadData()
        if self.day >= 0 && day < self.programs.count {
            
            let programs_today = self.programs[self.day]
            for program in programs_today {
                let start_hour:Int = Int(program.start.stringByReplacingOccurrencesOfString(":", withString: ""))!
                if( hour >= start_hour ) {
                    self.day_index += 1
                }
            }
            self.day_index -= 1
            if( self.day_index < programs_today.count ) {
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: self.day_index, inSection: self.day), atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
                })
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.displayProgram()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showFacebook() {
        var content = LinkShareContent(url: NSURL(string: "http://digital.100fm.co.il/")!,
                                       title: "",
                                       description: "",
                                       quote: "",
                                       imageURL: nil)
        content.hashtag = Hashtag("#100fmDigital")
        showShareDialog(content, mode: .Automatic)
    }
    
    func showShareDialog<C: ContentProtocol>(content: C, mode: ShareDialogMode = .Automatic) {
        let dialog = ShareDialog(content: content)
        dialog.presentingViewController = self
        dialog.mode = mode
        do {
            try dialog.show()
        } catch (let error) {
            let alert = UIAlertController(title: "Invalid share content", message: "Failed to present share dialog with error \(error)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: TableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
        
        let titleLabel = UILabel(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
        titleLabel.textColor = UIColor.init(red: 32/255, green: 116/250, blue: 168/255, alpha: 1)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont(name: "FbSpoiler-Black", size: 25)
        view.addSubview(titleLabel)
        
        switch section {
        case 0: titleLabel.text = "ראשון"
        case 1: titleLabel.text = "שני"
        case 2: titleLabel.text = "שלישי"
        case 3: titleLabel.text = "רביעי"
        case 4: titleLabel.text = "חמישי"
        case 5: titleLabel.text = "שישי"
        case 6: titleLabel.text = "שבת"
        default:
            titleLabel.text = self.programs[section][0].day
        }
        
        view.backgroundColor = UIColor.init(red: 255/255, green: 255/250, blue: 21/255, alpha: 1)
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return programs.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programs[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("program")! as! ProgramCell
        //cell.configureCell(cell, video: self.videos[indexPath.row])
        
        let p:Program = programs[indexPath.section][indexPath.row]
        cell.configureCell(p, anim: indexPath.section == self.day && indexPath.row == self.day_index )
        
        return cell
    }
    
}
