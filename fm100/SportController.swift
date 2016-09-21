//
//  SportController.swift
//  fm100
//
//  Created by Leonid Angarov on 19/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import HealthKit
import GRDB
import SwiftyJSON
import FacebookShare

class SportController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var locationManager: CLLocationManager!
    var seconds = 0.0
    var distance = 0.0
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    @IBOutlet weak var lblDistance:UILabel? = UILabel()
    @IBOutlet weak var lblTimer:UILabel? = UILabel()
    @IBOutlet weak var lblSpeed:UILabel? = UILabel()
    
    @IBOutlet weak var lblSpeedForKM:UILabel? = UILabel()
    @IBOutlet weak var lblCal:UILabel? = UILabel()
    
    @IBOutlet weak var btnStart:UIButton? = UIButton()
    @IBOutlet weak var btnRestart:UIButton? = UIButton()
    @IBOutlet weak var btnEnd:UIButton? = UIButton()
    @IBOutlet weak var viewGraph:UIView? = UIView()
    
    @IBOutlet weak var tableView:UITableView? = UITableView()
    
    @IBOutlet weak var imgSignal: UIImageView!
    
    var layerGraph:CAShapeLayer = CAShapeLayer()
    
    var isRunning:Bool = false
    
    var l: CALayer {
        return viewGraph!.layer
    }

    var isSummeryMode:Bool = false
    
    var loadingItems:Int = 0
    
    var run:[RunRecord] = [RunRecord]()
    var speeds:[Double] = [Double]()
    
    var archive:[RunRecord] = [RunRecord]()
    
    var currentRun:RunRecord = RunRecord()
    
    var pace:[Double] = [Double]()
    
    var avgSpeed = 0;
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let howRecent = location.timestamp.timeIntervalSinceNow
            
            if abs(howRecent) < 10 && location.horizontalAccuracy < 60 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                }
                
                //save location
                self.locations.append(location)
            }
            
            if( location.horizontalAccuracy < 30 ) {
                imgSignal.image = UIImage(named: "satellite1")!
            } else if( location.horizontalAccuracy < 60 ) {
                imgSignal.image = UIImage(named: "satellite2")!
            } else {
                imgSignal.image = UIImage(named: "satellite3")!
            }
        }
    }
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    func printSecondsToHoursMinutesSeconds (seconds : Int) -> (String) {
        let (h, m, s) = secondsToHoursMinutesSeconds (seconds)
        return h == 0 ? String(format: "%02d:%02d", m, s) : String(format: "%d:%02d:%02d", h, m, s)
    }
    
    func eachSecond(timer: NSTimer) {
        seconds += 1
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        let sec:Double = secondsQuantity.doubleValueForUnit(HKUnit.secondUnit())
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        let distancePace:Double = distanceQuantity.doubleValueForUnit(HKUnit.meterUnit())
        
        lblTimer!.text = printSecondsToHoursMinutesSeconds( Int(sec) )
        lblDistance!.text = String(format: "%.2f ק״מ", distancePace / 1000)
        
        run.append(RunRecord(time: sec, distance: distancePace) )
        
        let index = run.count > 5 ? run.count - 5 : 0
        let lastSeconds = run[run.count - 1].time - run[index].time
        
        var lastDistance = 0.0
        if( run.count > 2 ) {
            for i in index...(run.count - 2) {
                lastDistance += run[i+1].distance - run[i].distance
            }
        }
        
        let paceUnit = HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: lastDistance / lastSeconds)
        let speed = paceQuantity.doubleValueForUnit(paceUnit) * 3.6
        
        if( lastSeconds > 0 ) {
            speeds.append(speed)
        }
        
        if( lastSeconds > 0 ) {
            lblSpeed!.text = String(format: "%.1f קמ״ש", speed)
        }
        updateAnimation()
    }
    
    func showSummery() {
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        let sec:Double = secondsQuantity.doubleValueForUnit(HKUnit.secondUnit())
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        let distancePace:Double = distanceQuantity.doubleValueForUnit(HKUnit.meterUnit())
        
        lblTimer!.text = printSecondsToHoursMinutesSeconds( Int(sec) )
        lblDistance!.text = String(format: "%.2f ק״מ", distancePace / 1000)
    
        var totalSpeed:Double = 0
        if( run.count > 0 ) {
            
            pace.removeAll()
            var paceCount:Double = run[0].distance
            var speed:Double = 0
            var lastPaceIndex = 0
            
            for i in 1..<run.count {
                let lastDistance:Double = run[i].distance - run[i - 1].distance
                
                let paceUnit = HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
                let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: lastDistance / 1)
                
                speed = paceQuantity.doubleValueForUnit(paceUnit) * 3.6
                totalSpeed += speed
                speeds.append(speed)
                
                paceCount += lastDistance
                if( Int(paceCount) > pace.count * 1000 + 1000 ) {
                    lastPaceIndex = i
                    if pace.count == 0 {
                        pace.append(run[i].time)
                    } else {
                        pace.append(run[i].time - run[i-1].time)
                    }
                    
                }
            }
            if paceCount > 0 {
                pace.append( (run[run.count-1].time - run[lastPaceIndex].time) * 1000 / (paceCount % 1000) )
            }
            lblSpeed?.text = String(format: "%.1f קמ״ש", totalSpeed / Double(run.count) )
            
            var avgSpeed = 0;
            if( distance > 0 ) {
                avgSpeed = Int(seconds / distance * 1000);
            }
            lblSpeedForKM?.text = printSecondsToHoursMinutesSeconds( avgSpeed )
            var cardio:Double = 1.0 - Double(avgSpeed) / 5.0;
            if cardio > 1.3 {
                cardio  = 1.3
            }
            if cardio < 0.7 {
                cardio  = 0.7
            }
            lblCal!.text = String(format: "%.0f", distancePace / 1000 * 100 * cardio )
            
            
            updateAnimation()
        }
    }
    
    func startLocationManger() {
        run.removeAll()
        speeds.removeAll()
        isRunning = true
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters //kCLLocationAccuracyBest
            locationManager.activityType = .Fitness
            //locationManager.distanceFilter = 10.0
            
            let authstate = CLLocationManager.authorizationStatus()
            if(authstate == CLAuthorizationStatus.NotDetermined){
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.startUpdatingLocation()
            btnStart?.hidden = true
            btnEnd?.hidden = false
            btnRestart?.hidden = false
        }
    }
    
    func updateAnimation() {
        
        var max:Double = 0
        for i in speeds {
            if i > max {
                max = i
            }
        }
        
        let w = viewGraph!.frame.size.width / CGFloat(speeds.count)
        let graphPath = UIBezierPath()
        graphPath.moveToPoint(CGPoint(x: 0, y: viewGraph!.frame.size.height))
        
        var count:CGFloat = 0
        for i in speeds {
            let nextPoint = CGPoint(x: CGFloat(w * count),
                                    y: viewGraph!.frame.size.height * CGFloat( 1 - i / max ) )
            
            graphPath.addLineToPoint(nextPoint)
            
            count = count + 1.0
        }
        if speeds.count > 1 {
            graphPath.addLineToPoint(CGPoint(x: viewGraph!.frame.size.width, y: viewGraph!.frame.size.height * CGFloat( 1 - speeds[speeds.count - 1] / max )))
        }
        graphPath.addLineToPoint(CGPoint(x: viewGraph!.frame.size.width, y: viewGraph!.frame.size.height))
        
        let layer:CAShapeLayer = CAShapeLayer()
        layer.path = graphPath.CGPath
        layer.strokeColor = UIColor.init(red: 44.0/255.0, green: 68.0/255.0, blue: 143.0/255.0, alpha: 0.5).CGColor
        layer.lineWidth = 1.0
        layer.fillColor = isSummeryMode ? UIColor.init(red: 40.0/255.0, green: 106.0/255.0, blue: 170.0/255.0, alpha: 0.5).CGColor : UIColor.init(red: 22.0/255.0, green: 154.0/255.0, blue: 180.0/255.0, alpha: 0.5).CGColor
        
        layerGraph.removeFromSuperlayer()
        self.l.addSublayer(layer)
        layerGraph = layer
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showSummery") {
            let dest = segue.destinationViewController as! SportController
            dest.isSummeryMode = true
            
            if( currentRun.id != 0 ) {
                dest.seconds = currentRun.time
                dest.distance = currentRun.distance
                dest.run = self.loadRunJson( String(currentRun.id) )
            } else {
                dest.seconds = self.seconds
                dest.distance = self.distance
                dest.run = run
            }
        }
    }
    
    @IBAction func startSport(sender: AnyObject) {
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        imgSignal.hidden = false
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                       target: self,
                                                       selector: #selector(eachSecond),
                                                       userInfo: nil,
                                                       repeats: true)
        startLocationManger()
    }
    
    @IBAction func stopSport(sender: AnyObject) {
        isRunning = false
        locationManager.stopUpdatingLocation()
        timer.invalidate()
        btnStart?.hidden = false
        btnEnd?.hidden = true
        btnRestart?.hidden = true
        imgSignal.hidden = true
        
        layerGraph.removeFromSuperlayer()
        
        addRunToDatabase()
        
        self.performSegueWithIdentifier("showSummery", sender: self)
    }
    
    @IBAction func restartSport(sender: AnyObject) {
        if( isRunning ) {
            locationManager.stopUpdatingLocation()
            timer.invalidate()
            btnRestart?.setTitle("המשך", forState: UIControlState.Normal)
        } else {
            locationManager.startUpdatingLocation()
            timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                           target: self,
                                                           selector: #selector(eachSecond),
                                                           userInfo: nil,
                                                           repeats: true)
            btnRestart?.setTitle("הפסקה", forState: UIControlState.Normal)
        }
        isRunning = !isRunning
    }
    
    @IBAction func closeWindow(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { 
        }
    }
    
    @IBAction func toggleRightDrawer(_ sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.toggleRightDrawer(sender, animated: true)
    }
    
    func connectToDatabase() -> DatabaseQueue {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let dbPath = (documentsPath as NSString).stringByAppendingPathComponent("db100.sqlite")
        //print(dbPath)
        let dbQueue = try! DatabaseQueue(path: dbPath)
        return dbQueue
    }
    
    func addRunToDatabase() {
        let dbQueue = connectToDatabase()
        _ = try! dbQueue.inDatabase { db in
            try db.execute(
                "INSERT INTO running (seconds, distance) VALUES (?, ?)",
                arguments: [self.seconds, self.distance])
            
            let parisId = db.lastInsertedRowID
            self.saveRunJson(String(parisId), runs: self.run)
            self.loadDatabase()
        }
    }
    
    func saveRunJson(id:String, runs:[RunRecord]) {
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        try! documentsDirectoryPath.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
        
        let jsonFilePath = documentsDirectoryPath.URLByAppendingPathComponent("run" + id + ".json")
        
        let fileManager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = false
        
        if !fileManager.fileExistsAtPath(jsonFilePath!.absoluteString!, isDirectory: &isDirectory) {
            let created = fileManager.createFileAtPath(jsonFilePath!.absoluteString!, contents: nil, attributes: nil)
            if created {
                print("File created ")
            } else {
                print("Couldn't create file for some reason")
            }
        } else {
            print("File already exists")
        }
        
        var queue:[NSDictionary] = [NSDictionary]()
        
        for run in runs {
            queue.append(["time":run.time, "distance": run.distance])
        }
        
        let json: JSON =  ["seconds":self.seconds, "distance": self.distance, "runs": queue]
        
        do {
            let file = try NSFileHandle(forWritingToURL: jsonFilePath!)
            try file.writeData(json.rawData())
            print("JSON data was written to teh file successfully!")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    
    func loadRunJson(id:String) -> [RunRecord] {
        var runs:[RunRecord] = [RunRecord]()
        
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let jsonFilePath = documentsDirectoryPathString + "/run" + id + ".json"
        if let data = NSData(contentsOfFile: jsonFilePath) {
            
            let json = JSON(data: data)
            for (_,subJson):(String, JSON) in json["runs"] {
                runs.append(RunRecord(time: subJson["time"].doubleValue, distance: subJson["distance"].doubleValue))
            }
        }
        
        return runs
    }
    
    func loadDatabase() {
        let dbQueue = connectToDatabase()
        
        _ = try! dbQueue.inDatabase { db in
            try db.execute(
                "CREATE TABLE IF NOT EXISTS running (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                    "create_date DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                    "seconds INT NOT NULL DEFAULT 0, " +
                    "distance INT NOT NULL DEFAULT 0" +
                ")")
            
            self.archive.removeAll()
            for row in Row.fetchAll(db, "SELECT * FROM running ORDER BY create_date DESC", arguments: []) {
                self.archive.append(RunRecord(id: row.value(named: "id"),
                    create_date: row.value(named: "create_date"),
                    time: row.value(named: "seconds"),
                    distance: row.value(named: "distance")))
            }
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView?.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImageView(frame: CGRectMake(0, 0, 50, 20))
        img.image = UIImage(named: "fm1003")
        img.contentMode = UIViewContentMode.ScaleAspectFit
        self.navigationItem.titleView = img;
        
        if( isSummeryMode ) {
            showSummery()
        } else {
            self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "header"), forBarMetrics: .Default)
            loadDatabase();
        }
    }
    
    @IBAction func showFacebook() {
        let content = LinkShareContent(url: NSURL(string: "http://digital.100fm.co.il/")!,
                                       title: "",
                                       description: "",
                                       imageURL: nil)
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
        if( !isSummeryMode ) {
            currentRun = self.archive[indexPath.row]
            self.performSegueWithIdentifier("showSummery", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
        
        let titleLabel = UILabel(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
        titleLabel.textColor = UIColor.init(red: 32/255, green: 116/250, blue: 168/255, alpha: 1)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont(name: "FbSpoiler-light", size: titleLabel.font.pointSize)
        titleLabel.text = isSummeryMode ? "קצב ריצה" : "היסטורית פעילות גופנית"
        
        view.addSubview(titleLabel)
        view.backgroundColor = UIColor.whiteColor()
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSummeryMode {
            return self.pace.count == 0 ? 1 : self.pace.count
        }
        return self.archive.count == 0 ? 1 : self.archive.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.archive.count > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("workout")! as! RunCell
            
            let run:RunRecord = self.archive[indexPath.row]
            cell.configureCell(run)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("none")! as UITableViewCell
        cell.textLabel?.text = "לא נמצאו פעילויות"
        
        if isSummeryMode {
            if self.pace.count > 0 {
                cell.textLabel?.text = "קילומטר #" + String(indexPath.row+1) + " נמשך " + printSecondsToHoursMinutesSeconds(Int(self.pace[indexPath.row])) + " דקות"
                return cell
            } else {
                cell.textLabel?.text = "קילומטר #" + String(indexPath.row+1) + " נמשך " + String(avgSpeed) + " דקות"
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let r:RunRecord = self.archive[indexPath.row]
            
            let dbQueue = connectToDatabase()
            _ = try! dbQueue.inDatabase { db in
                try db.execute(
                    "DELETE FROM running WHERE id = ?",
                    arguments: [r.id])
                self.loadDatabase()
            }
            
            print("delete ", indexPath.row)
        }
    }
}
