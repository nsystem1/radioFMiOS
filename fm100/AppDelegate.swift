//
//  AppDelegate.swift
//  fm100
//
//  Created by Leonid Angarov on 06/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import UIKit
import KGFloatingDrawer
import Firebase
import Fabric
import Crashlytics
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var isMenuOpend:Bool = false
    
    let kKGDrawersStoryboardName = "Main"
    
    let kKGDrawerSettingsViewControllerStoryboardId = "KGDrawerSettingsViewControllerStoryboardId"
    let kKGDrawerWebViewViewControllerStoryboardId = "KGDrawerWebViewControllerStoryboardId"
    let kKGDrawerTimeTableViewControllerStoryboardId = "kKGDrawerTimeTableViewControllerStoryboardId"
    let kKGLeftDrawerStoryboardId = "KGLeftDrawerViewControllerStoryboardId"
    let kKGRightDrawerStoryboardId = "KGRightDrawerViewControllerStoryboardId"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window?.rootViewController = drawerViewController
        
        window?.makeKeyAndVisible()
        
        
        //Fabric.with([Answers.self])
        Fabric.with([Crashlytics.self])
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        UINavigationBar.appearance().translucent = true
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        FIRApp.configure()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(AppDelegate.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        drawerViewController.view.addGestureRecognizer(swipeRight)
        
        /*let mouseDrag:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AppDelegate.respondToSwipeGesture(_:)))
        mouseDrag.numberOfTouchesRequired = 1
        mouseDrag.minimumPressDuration = 0.2
        drawerViewController.view.addGestureRecognizer(mouseDrag)*/
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(AppDelegate.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        drawerViewController.view.addGestureRecognizer(swipeLeft)
        
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        if let launchOptions = launchOptions {
            let notificationPayload: NSDictionary = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as! NSDictionary!
            if let url = notificationPayload["url"] as? String {
                parserURL(url)
            }
        }
        
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let url = userInfo["url"] as? String {
            parserURL(url)
        }
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        parserURL(url.absoluteString!)
        
        return true
    }
    
    func parserURL( url:String ) {
        if url.rangeOfString("fm100") != nil{
            if let range = url.rangeOfString("?slug=") {
                FM100Api.shared.setPushVal( url.substringFromIndex(range.endIndex) )
                NSNotificationCenter.defaultCenter().postNotificationName("RemotePushReceivedNotification", object: nil)
            }
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Prod)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        //NSNotificationCenter.defaultCenter().postNotificationName("appStatusBackgroud", object: nil)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("appStatusBackgroud", object: nil)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("appStatusActive", object: nil)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("appStatusInterruption", object: nil)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        print("applicationWillTerminate")
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                if isMenuOpend {
                    toggleRightDrawer(self, animated: true)
                }
            case UISwipeGestureRecognizerDirection.Left:
                if !isMenuOpend {
                    toggleRightDrawer(self, animated: true)
                }
            default:
                break
            }
        }
    }
    
    private var _drawerViewController: KGDrawerViewController?
    var drawerViewController: KGDrawerViewController {
        get {
            if let viewController = _drawerViewController {
                return viewController
            }
            return prepareDrawerViewController()
        }
    }
    
    func prepareDrawerViewController() -> KGDrawerViewController {
        let drawerViewController = KGDrawerViewController()
        
        drawerViewController.centerViewController = drawerSettingsViewController()
        drawerViewController.leftViewController = leftViewController()
        drawerViewController.rightViewController = rightViewController()
        drawerViewController.backgroundImage = UIImage(named: "bg")
        
        _drawerViewController = drawerViewController
        
        return drawerViewController
    }
    
    private func drawerStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: kKGDrawersStoryboardName, bundle: nil)
        return storyboard
    }
    
    private func viewControllerForStoryboardId(storyboardId: String) -> UIViewController {
        let viewController: UIViewController = drawerStoryboard().instantiateViewControllerWithIdentifier(storyboardId)
        return viewController
    }
    
    func drawerSettingsViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(kKGDrawerSettingsViewControllerStoryboardId)
        return viewController
    }
    
    func sourcePageViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(kKGDrawerWebViewViewControllerStoryboardId)
        return viewController
    }
    
    func timePageViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(kKGDrawerTimeTableViewControllerStoryboardId)
        return viewController
    }
    
    private func leftViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(kKGLeftDrawerStoryboardId)
        return viewController
    }
    
    private func rightViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(kKGRightDrawerStoryboardId)
        return viewController
    }
    
    func toggleLeftDrawer(sender:AnyObject, animated:Bool) {
        _drawerViewController?.toggleDrawer(.Left, animated: true, complete: { (finished) -> Void in
            // do nothing
        })
    }
    
    func toggleRightDrawer(sender:AnyObject, animated:Bool) {
        _drawerViewController?.toggleDrawer(.Right, animated: true, complete: { (finished) -> Void in
            // do nothing
            self.isMenuOpend = !self.isMenuOpend
        })
    }
    
    private var _centerViewController: UIViewController?
    var centerViewController: UIViewController {
        get {
            if let viewController = _centerViewController {
                return viewController
            }
            return drawerSettingsViewController()
        }
        set {
            if let drawerViewController = _drawerViewController {
                drawerViewController.closeDrawer(drawerViewController.currentlyOpenedSide, animated: true) { finished in }
                if drawerViewController.centerViewController != newValue {
                    drawerViewController.centerViewController = newValue
                }
            }
            _centerViewController = newValue
        }
    }
}
