//
//  NavigationController.swift
//  Chat App
//
//  Created by Kevin Li on 10/21/19.
//  Copyright © 2019 Kevin Li. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
  
  init(_ rootVC: UIViewController) {
    super.init(nibName: nil, bundle: nil)
    pushViewController(rootVC, animated: true)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationBar.tintColor = .primary
    navigationBar.prefersLargeTitles = true
    navigationBar.titleTextAttributes = [.foregroundColor: UIColor.primary]
    navigationBar.largeTitleTextAttributes = navigationBar.titleTextAttributes
    
    toolbar.tintColor = .primary
  }
  
  override var shouldAutorotate: Bool {
    return false
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return topViewController?.preferredStatusBarStyle ?? .default
  }
  
}

