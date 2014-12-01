//
//  AppDelegate.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 10/11/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Anytime the app is brought to the forground, the timer duration preference
    // could have been changed.  Check to see if the timer is currently active
    // (active: paused or counting down, but not already reset and waiting to start)
    // If the timer is not active, then reset the timer so that it reads the new
    // timer duration preference and updates the UI to reflect it.
    //
    // This assumes that the rootViewController is our 'ViewController' class
    lazy var timerViewController: TimerViewController = {
        let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        return rootViewController as TimerViewController
    }()

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        // https://stackoverflow.com/questions/26461689/ios-state-restoration-animation-bug/26591842#26591842?newreg=72c20853498146b7a00cc5351ba502c2&newUserTooltips=true
        self.window?.makeKeyAndVisible()
        return true
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        timerViewController.timer.transitionToHidden()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        timerViewController.timer.transitionToHidden()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        timerViewController.timer.transitionToVisible()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        timerViewController.timer.transitionToVisible()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        timerViewController.timer.transitionToHidden()
    }
    
    
    
}

