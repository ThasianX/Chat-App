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
    
    var window: UIWindow?
    private var mainCoordinator: MainCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        let window = UIWindow(frame: UIScreen.main.bounds)
        let mainCoordinator = MainCoordinator(window: window)
        
        self.window = window
        self.mainCoordinator = mainCoordinator
        
        mainCoordinator.start()
        return true
    }
}

