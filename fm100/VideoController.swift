//
//  SecondViewController.swift
//  fm100
//
//  Created by Leonid Angarov on 06/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import FacebookShare

class VideoController: UIViewController, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var web:UIWebView? = UIWebView()
    @IBOutlet weak var list:UITableView? = UITableView()
    @IBOutlet weak var loading:UIActivityIndicatorView? = UIActivityIndicatorView()
    
    var videos:[VideoYouTube] = [VideoYouTube]()
    
    var loadingItems:Int = 0

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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoController.methodOfReceivedNotification(_:)), name:"reloadStationsNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoController.videoFullscreenStarted), name:"UIWindowDidBecomeVisibleNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoController.videoFullscreenStoped), name:"UIWindowDidBecomeHiddenNotification", object: nil)

        web?.delegate = self
        //web?.loadRequest(NSURLRequest(URL: NSURL(string: "http://100fm.multix.co.il/")!))
        web?.loadHTMLString("<html><body style=\"margin: 0;\"><video width=\"100%\" height=\"100%\" preload=\"none\" poster=\"http://assets-jpcust.jwpsrv.com/thumbs/teD8sDdM-720.jpg\"><source type=\"application/x-mpegURL\" src=\"http://hlscdn.streamgates.net/radios100fm/abr/playlist.m3u8\" /></video></body></html>", baseURL: nil)
        
        reloadData()
    }
    
    func videoFullscreenStarted() {
        NSNotificationCenter.defaultCenter().postNotificationName("appStopRadio", object: nil)
    }
    
    func videoFullscreenStoped() {
        NSNotificationCenter.defaultCenter().postNotificationName("appStartRadio", object: nil)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(request.URL?.absoluteString)
        return true;
    }
    
    func webViewDidStartLoad(webView : UIWebView) {
        loadingItems += 1
        loading?.hidden = false;
        web?.hidden = true
    }
    
    func webViewDidFinishLoad(webView : UIWebView) {
        loadingItems -= 1
        if( loadingItems == 0 ) {
            loading?.hidden = true;
            web?.hidden = false
            
            let loadStyles = "var script = document.createElement('style'); script.innerHTML = 'body { margin: 0; height: 100%; } .jwplayer.jw-flag-aspect-mode { height: 100% !important; }'; document.getElementsByTagName('body')[0].appendChild(script);"
            
            web!.stringByEvaluatingJavaScriptFromString(loadStyles)
        }
    }
    
    func reloadData() {
        videos = FM100Api.shared.youtube
        videos.insert(VideoYouTube( id: "live", title: "רדיוס 100FM לייב", thumbnail: "http://assets-jpcust.jwpsrv.com/thumbs/teD8sDdM-720.jpg"), atIndex: 0)
        list?.reloadData()
    }
    
    func methodOfReceivedNotification(notification: NSNotification){
        reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let video:VideoYouTube = videos[indexPath.row]
        
        if( video.id == "live") {
            web?.loadHTMLString("<html><body style=\"margin: 0;\"><video width=\"100%\" height=\"100%\" preload=\"none\" poster=\"http://assets-jpcust.jwpsrv.com/thumbs/teD8sDdM-720.jpg\"><source type=\"application/x-mpegURL\" src=\"http://hlscdn.streamgates.net/radios100fm/abr/playlist.m3u8\" /></video></body></html>", baseURL: nil)
            //web?.loadRequest(NSURLRequest(URL: NSURL(string: "http://100fm.multix.co.il/")!))
        } else {
            web?.loadRequest(NSURLRequest(URL: NSURL(string: "https://www.youtube.com/embed/" + video.id)!))
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("youtube") as! YouTubeCell
        cell.configureCell(cell, video: self.videos[indexPath.row])
        
        return cell
    }


}

