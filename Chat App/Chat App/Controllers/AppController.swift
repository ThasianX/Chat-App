//
//  AppController.swift
//  Chat App
//
//  Created by Kevin Li on 10/21/19.
//  Copyright © 2019 Kevin Li. All rights reserved.
//

import UIKit
import Firebase

final class AppController {
  
  static let shared = AppController()
  
  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(userStateDidChange),
      name: Notification.Name.AuthStateDidChange,
      object: nil
    )
  }
  
  private var window: UIWindow!
  private var rootViewController: UIViewController? {
    didSet {
      if let vc = rootViewController {
        window.rootViewController = vc
      }
    }
  }
  
  // MARK: - Helpers
  
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
      rootViewController = NavigationController(vc)
    } else {
      let vc = LandingScreenVC(nibName: "LandingScreenVC", bundle: nil)
      rootViewController = NavigationController(vc)
    }
  }
  
    
    func login(){
        let vc = LoginScreenVC(nibName: "LoginScreenVC", bundle: nil)
        rootViewController = NavigationController(vc)
    }
    
    func signUp(){
        let vc = SignUpScreenVC(nibName: "SignUpScreenVC", bundle: nil)
        rootViewController = NavigationController(vc)
    }
    
  // MARK: - Notifications
  
  @objc internal func userStateDidChange() {
    DispatchQueue.main.async {
      self.handleAppState()
    }
  }
  
}
