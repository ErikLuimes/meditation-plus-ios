//
//  AppDelegate.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//  Copyright (c) 2015 Maya Interactive
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class MPAppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool
    {
        Fabric.with([Crashlytics.self])

        application.cancelAllLocalNotifications()

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = MPMenuContainerViewController()
        window!.backgroundColor = UIColor.whiteColor()
        window!.makeKeyAndVisible()

        setupDefaults()
        setupMeditationTimer()

        return true
    }

    func setupDefaults()
    {
        NSUserDefaults.standardUserDefaults().registerDefaults([
            "rememberPassword": false,
            "walkingMeditationTimeId": 30,
            "sittingMeditationTimeId": 30
        ])

        if (NSUserDefaults.standardUserDefaults().URLForKey("avatar") == nil) {
            let url = NSURL(string: "http://www.gravatar.com/avatar/00000000000000000000000000000000?d=mm&f=y&s=140")!
            NSUserDefaults.standardUserDefaults().setURL(url, forKey: "avatar")
        }
    }

    func setupMeditationTimer()
    {
        MeditationTimer.sharedInstance.addDelegate(AudioPlayerManager.sharedInstance)
        MeditationTimer.sharedInstance.addDelegate(IdleTimeoutMeditationTimerDelegate.sharedInstance)
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification)
    {
        NSLog("did receive local notification")
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
        MeditationTimer.sharedInstance.applicationWillEnterForeground()
    }

    func applicationDidEnterBackground(application: UIApplication)
    {
        MeditationTimer.sharedInstance.applicationDidEnterBackground()
    }

    func applicationWillTerminate(application: UIApplication)
    {
        application.cancelAllLocalNotifications()
    }

}