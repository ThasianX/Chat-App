//
//  MainCoordinator.swift
//  Chat App
//
//  Created by Kevin Li on 10/23/19.
//  Copyright © 2019 Kevin Li. All rights reserved.
//

import UIKit
import Firebase

final class MainCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    let window: UIWindow
    var rootViewController: UINavigationController
    
    init(window: UIWindow) {
        FirebaseApp.configure()
        
        self.window = window
        window.tintColor = .primary
        window.backgroundColor = .white
        
        rootViewController = UINavigationController()
        rootViewController.navigationBar.tintColor = .primary
        rootViewController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.primary]
        rootViewController.navigationBar.largeTitleTextAttributes = rootViewController.navigationBar.titleTextAttributes
        
        rootViewController.toolbar.tintColor = .primary
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userStateDidChange),
            name: Notification.Name.AuthStateDidChange,
            object: nil
        )
    }
    
    func start() {
        handleAppState()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    private func handleAppState() {
        if let user = Auth.auth().currentUser {
            let vc = ChannelsVC(currentUser: user)
            rootViewController.pushViewController(vc, animated: true)
        } else {
            let vc = LandingScreenVC(nibName: "LandingScreenVC", bundle: nil)
            vc.coordinator = self
            rootViewController.pushViewController(vc, animated: true)
        }
    }
    
    func login(){
        let vc = LoginScreenVC(nibName: "LoginScreenVC", bundle: nil)
        rootViewController.pushViewController(vc, animated: true)
    }
    
    func signUp(){
        let vc = SignUpScreenVC(nibName: "SignUpScreenVC", bundle: nil)
        rootViewController.pushViewController(vc, animated: true)
    }
    
    @objc internal func userStateDidChange() {
        DispatchQueue.main.async {
            self.handleAppState()
        }
    }
}
