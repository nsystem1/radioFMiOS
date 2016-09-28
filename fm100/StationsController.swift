//
//  FirstViewController.swift
//  fm100
//
//  Created by Leonid Angarov on 06/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import UIKit
import MediaPlayer
import MessageUI
import Social
import Alamofire
import SwiftyJSON
import SwiftyXMLParser
import Kingfisher
import FacebookShare
import Firebase

class StationsController: UIViewController, StationDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var list:StationsList? = StationsList()
    @IBOutlet weak var btnPlay:UIButton? = UIButton()
    @IBOutlet weak var imgPlayRound:UIImageView? = UIImageView()
    @IBOutlet weak var indPlayLoading:UIActivityIndicatorView? = UIActivityIndicatorView()
    @IBOutlet weak var lblSong:UILabel? = UILabel()
    @IBOutlet weak var lblArtist:UILabel? = UILabel()
    @IBOutlet weak var viewGraph:UIView? = UIView()
    @IBOutlet weak var btnDownload: UIButton!
    
    @IBOutlet weak var imgCover:UIImageView! = UIImageView()
    @IBOutlet weak var imgCover1:UIImageView! = UIImageView()
    
    
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var btnTry: UIButton!
    
    var iMinSessions = 3
    var iTryAgainSessions = 6
    
    var covers:[UIImageView] = [UIImageView]()
    
    var layerGraph:CAShapeLayer = CAShapeLayer()
    
    var arrow1: UIImageView!
    var arrow2: UIImageView!
    
    let captureAudioSession = AVCaptureSession()
    
    let animSpeed:Double = 1 / 10
    
    var player = AVPlayer()
    var graphIndex:Int = 0
    var graphData:JSON = 0
    
    var currentStation:Station = Station()
    var isPlaying:Bool = false;
    var isAnimationGoing:Bool = false;
    var timer:NSTimer = NSTimer()
    var timerAnimation:NSTimer = NSTimer()
    
    var views:[UIView] = [UIView]()
    var offset1:Double = 0
    var offset2:Double = 0
    
    var lastSong:String = ""
    var lastArtist:String = ""
    
    var mainColor:UIColor = UIColor.yellowColor()
    
    var isInterruption:Bool = false
    var isConnected:Bool = false
    
    @IBAction func clickPlay() {
        
        if( !self.isConnected ) {
            checkInternet()
            return
        }
        
        if( isPlaying ) {
            stopRadio()
        } else {
            startRadio()
        }
    }
    
    @IBAction func showFacebook() {
        let content = LinkShareContent(url: NSURL(string: "http://digital.100fm.co.il/#" + currentStation.slug)!,
                                       title: "",
                                       description: "",
                                       quote: "\"" + lastSong.capitalizedString + "\" BY " + lastArtist.capitalizedString,
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
    
    @IBAction func clickOpenItunes() {
        UIApplication.sharedApplication().openURL(NSURL(string: btnDownload.accessibilityValue! + "&at=1010lpjn")!)
    }
    
    @IBAction func clickStationInfo() {
        let alertController = UIAlertController(title: currentStation.name, message: currentStation.description, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "לסגירה", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func StationChanged(index:Int) {
        changeStation(index)
        
        FIRAnalytics.logEventWithName("change_channel", parameters: [
            "name": self.currentStation.slug,
            "full_text": self.currentStation.name
            ])
    }
    
    func changeSongDisplay( name:String, artist:String, cache:Bool) {
        if( cache ) {
            self.lastSong = name
            self.lastArtist = artist
        }
        
        self.lblSong!.text = name.capitalizedString
        self.lblArtist!.text = artist.capitalizedString
        
        let nowPlayingInfo = [MPMediaItemPropertyArtist : artist.capitalizedString,  MPMediaItemPropertyTitle : name.capitalizedString, MPMediaItemPropertyArtwork : MPMediaItemArtwork(image:UIImage(named: "share")!)]
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nowPlayingInfo
    }
    
    func hideDownloadButton() {
        self.btnDownload.hidden = true
    }
    
    func showDownloadButton( image:String, url:String ) {
        self.btnDownload.accessibilityValue = url
        self.btnDownload.kf_setImageWithURL(NSURL(string: image)!, forState: UIControlState.Normal)
        self.btnDownload.hidden = false
    }
    
    func hideBackgroundImage() {
        self.mainColor = self.currentStation.color
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveLinear, animations: {
            self.covers[0].layer.opacity = 0
            self.covers[1].layer.opacity = 0
        }) { finished in
        }
    }
    
    func changeBackgroundImage( image:String ) {
        let img1:UIImageView = self.covers[0]
        let img2:UIImageView = self.covers[1]
        
        img2.kf_setImageWithURL(
            NSURL(string: image)!,
            placeholderImage: nil,
            optionsInfo: nil,
            progressBlock: nil,
            completionHandler: { (image, error, cacheType, imageURL) -> () in
                let pixelData = CGDataProviderCopyData(CGImageGetDataProvider((image?.CGImage)!)!)
                let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
                
                let pixelInfo: Int = 0//((Int(self.view.frame.size.width) * Int(self.view.frame.size.width/2)) + Int(self.view.frame.size.height/2)) * 4
                
                let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
                let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
                let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
                let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
                
                if r == g && g == b && b == r {
                    self.mainColor = self.currentStation.color
                    self.hideBackgroundImage()
                    self.hideDownloadButton()
                    return
                }
                
                self.mainColor = UIColor(red: r, green: g, blue: b, alpha: a)
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveLinear, animations: {
                    img1.layer.opacity = 0
                    img2.layer.opacity = 1
                }) { finished in
                    self.covers = [img2, img1]
                }
        })
    }
    
    func getRadioProgram() {
        FM100Api.shared.getPrograms { (status) in
            if( status ) {
                let todayDate = NSDate()
                let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                let myComponents = myCalendar?.components([.Weekday, .Hour], fromDate: todayDate)
                let weekDay:Int = ( myComponents!.weekday + 6 ) % 7
                let hour:Int = (myComponents?.hour)! * 100
                
                if weekDay >= 0 && weekDay < 8 {
                    
                    let programs = FM100Api.shared.programs[weekDay]
                    var currentProgram:Program = programs[0]
                    for program in programs {
                        let start_hour:Int = Int(program.start.stringByReplacingOccurrencesOfString(":", withString: ""))!
                        if( hour >= start_hour ) {
                            currentProgram = program
                        }
                    }
                    self.changeSongDisplay(currentProgram.name, artist: currentProgram.author == "" ? self.lastArtist : currentProgram.author, cache: false)
                    
                    if currentProgram.image == "" {
                        self.hideBackgroundImage()
                    } else {
                        self.changeBackgroundImage(currentProgram.image)
                    }
                }
            }
        }
    }
    
    func reloadSongName() {
        FM100Api.shared.getSongXML(currentStation.info) { xml, error in
            
            if( error == nil ) {
                var name:String = ""
                var artist:String = ""
                
                if xml["track"]["name"].text != nil {
                    name = xml["track"]["name"].text!
                }
                
                if xml["track"]["artist"].text != nil {
                    artist = xml["track"]["artist"].text!
                }
                if artist != "" && artist != " " && self.lastSong != name {
                    self.changeSongDisplay(name, artist: artist, cache: true)
                    
                    if self.currentStation.slug != "100fm" {
                        let key:String = name + " " + artist
                        Alamofire.request(.GET, "https://itunes.apple.com/search?limit=1&country=IL&term=" + key.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!).responseJSON { response in
                            if( response.result.value != nil ) {
                                self.changeDarken(self.covers[1], dark: 0.9)
                                let result:JSON = JSON(response.result.value!)
                                if result["resultCount"].intValue > 0 {
                                    let data:JSON = result["results"][0]
                                    
                                    self.showDownloadButton(data["artworkUrl30"].stringValue, url: data["trackViewUrl"].stringValue)
                                    
                                    self.changeBackgroundImage(data["artworkUrl100"].stringValue.stringByReplacingOccurrencesOfString("100x100", withString: "400x400"))
                                } else {
                                    self.hideDownloadButton()
                                    self.hideBackgroundImage()
                                }
                            }
                        }
                    } else {
                        self.changeDarken(self.covers[1], dark: 0.6)
                        
                        self.getRadioProgram()
                        self.hideDownloadButton()
                    }
                } else {
                    FM100Api.shared.addFavChannel(self.currentStation.slug)
                }
            } else {
                self.hideDownloadButton()
            }
        }
    }
    
    
    func changeDarken(img:UIImageView, dark:Float) {
        //print("dark ", dark)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = (img.bounds)
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        blurEffectView.layer.opacity = dark
        if img.subviews.count > 0 {
            img.subviews[0].removeFromSuperview()
        }
        img.addSubview(blurEffectView)
    }
    func startRadio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                
                isPlaying = true
                isAnimationGoing = true
                btnPlay?.setImage(UIImage(named: "stop"), forState: UIControlState.Normal)
                
                reloadSongName();
                
                startAnimation()
                
                let playerItem = AVPlayerItem( URL:NSURL( string:currentStation.audio )! )
                
                player = AVPlayer(playerItem:playerItem)
                player.rate = 1
                player.play()
                
                let nowPlayingInfo = [MPMediaItemPropertyArtist : "100FM רדיוס",  MPMediaItemPropertyTitle : self.currentStation.name, MPMediaItemPropertyArtwork : MPMediaItemArtwork(image:UIImage(named: "share")!)]
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nowPlayingInfo
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioInterruption), name: AVAudioSessionInterruptionNotification, object: nil)
                
                UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
                self.becomeFirstResponder()
                
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    func stopRadio() {
        stopAnimation()
        
        btnPlay?.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
        
        //btnPlay?.hidden = false
        //indPlayLoading?.hidden = true
        
        isPlaying = false;
        player.pause()
        
        //UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        //self.resignFirstResponder()
    }
    
    func audioInterruption() {
        isInterruption = true
        stopRadio()
    }
    
    func startAnimation() {
        //print("startAnimation")
        timerAnimation = NSTimer(fireDate: NSDate().dateByAddingTimeInterval(0), interval: animSpeed, target: self, selector: #selector(updateAnimation2), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timerAnimation, forMode: NSRunLoopCommonModes)
    }
    
    func stopAnimation() {
        //print("stopAnimation")
        timerAnimation.invalidate()
    }
    
    func randomNumber(range: Range<Int> = 1...6) -> Int {
        let min = range.startIndex
        let max = range.endIndex
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }
    
    func updateAnimation2() {
        if( randomNumber(1...3) == 1 ) {
            let s:CGFloat = CGFloat( randomNumber(10...40) )
            let v:UIView = UIView(frame: CGRectMake( CGFloat(randomNumber(-40...Int(self.view.frame.size.width))), self.view.frame.size.height + s + 64, s, s))
            v.backgroundColor = currentStation.color
            v.layer.opacity = 0.3
            
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(0, 0))
            path.addLineToPoint(CGPointMake(s, 0))
            path.addLineToPoint(CGPointMake(0, s))
            
            let layer:CAShapeLayer = CAShapeLayer()
            layer.path = path.CGPath
            layer.fillColor = mainColor.CGColor//currentStation.color.CGColor
            v.layer.addSublayer(layer)
            
            v.backgroundColor = UIColor.clearColor()
            viewGraph!.addSubview(v)
            
            views.append(v)
            
            UIView.animateWithDuration(animSpeed * 30, delay: 0.0, options: .CurveLinear, animations: {
                v.frame = CGRectMake(v.frame.origin.x, -s, s, s)
                v.layer.opacity = 2.0
                
                let d:CGFloat = CGFloat( self.randomNumber() % 100 )
                v.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) - 2 * CGFloat(M_PI) * d)
            }) { finished in
                if( self.views.count > 10 ) {
                    let v:UIView = self.views[0]
                    v.removeFromSuperview()
                    self.views.removeAtIndex(0)
                }
            }
        }
        
        UIView.animateWithDuration(animSpeed, delay: 0.0, options: .CurveLinear, animations: {
            self.imgPlayRound!.transform = CGAffineTransformRotate(self.imgPlayRound!.transform, CGFloat(M_PI) / 20.0)
        }) { finished in
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if( keyPath == "status" ) {
            btnPlay?.hidden = false
            indPlayLoading?.hidden = true
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        let rc = event!.subtype
        
        switch rc {
        case .RemoteControlTogglePlayPause:
            if isPlaying { self.stopRadio() } else { self.startRadio() }
        case .RemoteControlPlay:
            self.startRadio()
        case .RemoteControlPause:
            self.stopRadio()
        case .RemoteControlNextTrack:
            list?.getNextStation()
        case .RemoteControlPreviousTrack:
            list?.getPrevStation()
        default:break
        }
        self.stopAnimation()
    }
    
    @IBAction func toggleRightDrawer(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.toggleRightDrawer(sender, animated: true)
    }
    
    func checkInternet() {
        self.isConnected = Reachability.isConnectedToNetwork()
        if ( self.isConnected ) {
            lblError.hidden = true
            btnTry.hidden = true
            list!.hidden = false
            viewGraph!.hidden = false
            reloadStations()
        } else {
            lblError.hidden = false
            btnTry.hidden = false
            list!.hidden = true
            viewGraph!.hidden = true
        }
    }
    
    @IBAction func clickCheckInternet() {
        checkInternet()
        lblError.text = "נראה שזה עדין לא זז..."
    }
    
    
    
    @IBAction func clickGotoLive() {
        list?.changeStation(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let logo = UIImage(named: "fm1003")
        let btn = UIButton(frame: CGRectMake(0, 0, 50, 20));
        btn.setImage(UIImage(named: "fm1003"), forState: UIControlState.Normal)
        btn.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        btn.addTarget(self, action: #selector(StationsController.clickGotoLive), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.titleView = btn;
        
        covers = [imgCover, imgCover1]
        
        list?.delegateStation = self
        
        self.arrow1 = UIImageView(image: UIImage(named: "arrow-right"))
        self.arrow1.hidden = true
        self.view.addSubview(self.arrow1)
        list?.arrow1 = self.arrow1
        
        self.arrow2 = UIImageView(image: UIImage(named: "arrow-left"))
        self.arrow2.hidden = true
        self.view.addSubview(self.arrow2)
        list?.arrow2 = self.arrow2
        
        timer = NSTimer(fireDate: NSDate().dateByAddingTimeInterval(10), interval: 10, target: self, selector: #selector(reloadSongName), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StationsController.changeStationsNotification(_:)), name:"changeStationsNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StationsController.stopAnimationNotification(_:)), name:"appStatusBackgroud", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StationsController.startAnimationNotification(_:)), name:"appStatusActive", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StationsController.startInterruptionNotification(_:)), name:"appStatusInterruption", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StationsController.stopRadio), name:"appStopRadio", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StationsController.startRadio), name:"appStartRadio", object: nil)
        
        
        let volume:SubtleVolume = SubtleVolume(style: .Plain)
        volume.frame = CGRect(x: 0, y: 64, width: view.frame.size.width, height: 2)
        volume.barTintColor = UIColor.yellowColor()
        volume.animation = .SlideDown
        view.addSubview(volume)
        
        self.btnDownload.layer.borderWidth = 1.0
        self.btnDownload.layer.cornerRadius = 10.0
        self.btnDownload.layer.borderColor = UIColor.init(white: 1.0, alpha: 0.5).CGColor //UIColor.whiteColor().CGColor
        
        for img in covers {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = (img.bounds)
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            blurEffectView.layer.opacity = 0.9
            img.addSubview(blurEffectView)
            img.contentMode = .ScaleAspectFill
        }
        
        rateMe()
    }
    
    func rateMe() {
        let neverRate = NSUserDefaults.standardUserDefaults().boolForKey("neverRate")
        var numLaunches = NSUserDefaults.standardUserDefaults().integerForKey("numLaunches") + 1
        
        if (!neverRate && (numLaunches == iMinSessions || numLaunches >= (iMinSessions + iTryAgainSessions + 1)))
        {
            showRateMe()
            numLaunches = iMinSessions + 1
        }
        NSUserDefaults.standardUserDefaults().setInteger(numLaunches, forKey: "numLaunches")
    }
    
    func showRateMe() {
        let alert = UIAlertController(title: "דרגו אותנו", message: "תודה רבה על השימוש באפליקציה של רדיוס 100FM\nתרצו לדרג אותנו באפ סטור?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "דרג את האפליקציה", style: UIAlertActionStyle.Default, handler: { alertAction in
            UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id946941095")!)
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "לא תודה", style: UIAlertActionStyle.Default, handler: { alertAction in
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "neverRate")
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "בפעם אחרת", style: UIAlertActionStyle.Default, handler: { alertAction in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func changeStationsNotification(notification: NSNotification){
        let index:Int = (notification.object as? Int)!
        self.changeStation( index )
        self.list?.changeStation(index)
    }
    func startAnimationNotification(notification: NSNotification){
        if isPlaying {
            startAnimation()
        }
    }
    
    func startInterruptionNotification(notification: NSNotification){
        if( isInterruption ) {
            isInterruption = false
            if isPlaying {
                stopAnimation()
                startRadio();
            }
        }
    }
    
    func stopAnimationNotification(notification: NSNotification){
        if isPlaying {
            stopAnimation()
        }
    }
    
    func changeStation(index:Int) {
        let station = FM100Api.shared.stations[index]
        if( self.currentStation.slug != station.slug ) {
            self.currentStation = FM100Api.shared.stations[index]
            stopRadio()
            startRadio();
        }
    }
    
    func loadGraphData() {
        if let path = NSBundle.mainBundle().pathForResource("fake", ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                graphData = JSON(data: data)
                if graphData == JSON.null {
                    print("could not get json from file, make sure that file contains valid json.")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    func reloadStations() {
        if( !FM100Api.shared.isDataLoaded ) {
            FM100Api.shared.getInfo({ status in
                dispatch_async(dispatch_get_main_queue(),{
                    if( status ) {
                        //self.currentStation = FM100Api.shared.stations[0]
                        self.changeStation(0)
                        self.list?.setStations(FM100Api.shared.stations)
                        //self.startRadio();
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("reloadStationsNotification", object: nil)
                    }
                })
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        checkInternet()
        self.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        //UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        //self.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        //UIApplication.sharedApplication().endReceivingRemoteControlEvents()
    }
    
    override func viewDidLayoutSubviews() {
        self.list?.reloadLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
