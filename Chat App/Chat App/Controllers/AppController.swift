//
//  MainCoordinator.swift
//  Chat App
//
//  Created by Kevin Li on 10/23/19.
//  Copyright © 2019 Kevin Li. All rights reserved.
//

import UIKit
import Firebase

final class AppController {
    
    static let shared = AppController()
    private var window: UIWindow!
    private var rootViewController: UIViewController?
    
    init() {
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(userStateDidChange),
          name: Notification.Name.AuthStateDidChange,
          object: nil
        )
    }
    
    func show(in window: UIWindow?) {
      guard let window = window else {
        fatalError("Cannot layout app with a nil window.")
      }
      
      FirebaseApp.configure()
      
      self.window = window
      window.tintColor = .primary
      window.backgroundColor = .white
      
      handleAppState()
      
      window.makeKeyAndVisible()
    }
    
    private func handleAppState() {
        if let user = Auth.auth().currentUser {
            let vc = ChannelsVC(currentUser: user)
            rootViewController = vc
            window.rootViewController = UINavigationController(rootViewController: vc)
        } else {
            let vc = LandingScreenVC(nibName: "LandingScreenVC", bundle: nil)
            rootViewController = vc
            window.rootViewController = UINavigationController(rootViewController: vc)
        }
    }
    
    @objc internal func userStateDidChange() {
        DispatchQueue.main.async {
            self.handleAppState()
        }
    }
}
