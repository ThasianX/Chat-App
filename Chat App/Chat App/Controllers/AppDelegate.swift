//
//  AppDelegate.swift
//  Chat App
//
//  Created by Kevin Li on 10/20/19.
//  Copyright © 2019 Kevin Li. All rights reserved.
//

import UIKit
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        AppController.shared.show(in: UIWindow(frame: UIScreen.main.bounds))
        
        return true
    }
}

