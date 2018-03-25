//
//  AppDelegate.swift
//  FlappyBird
//
//  Created by Nate Murray on 6/2/14.
//  Copyright (c) 2014 Fullstack.io. All rights reserved.
//

import UIKit
import Allow2

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    var allow2Timer : Timer?
    let allow2Activities = [
        Allow2.Allow2Activity(activity: Allow2.Activity.Gaming, log: true),
        Allow2.Allow2Activity(activity: Allow2.Activity.ScreenTime, log: true)
    ]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Allow2.shared.deviceToken = "8nxEst2VyCVVrxUm"
        //Allow2.shared.env = .staging
        // for more options see the README
        // or set everything from the info.plist
        Allow2.shared.setPropsFromBundle(Bundle.main.infoDictionary?["Allow2"])
        startAllow2Timer()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        startAllow2Timer()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Allow2.shared.childId = nil
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate {
    
    func startAllow2Timer() {
        if (allow2Timer == nil) {
            allow2Timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(AppDelegate.checkAllow2), userInfo: nil, repeats: true)
            self.checkAllow2()
        }
    }
    
    @objc public func checkAllow2() {
        // this is called every 10 seconds. On each call, we blindly ask permission,
        // which will fail if there is no "default" child
        // on failure, we can check if we are actually paired, and if so,
        // then we can prompt for the user to select WHO they are
        Allow2.shared.check(activities: allow2Activities, log: true)
    }
}
