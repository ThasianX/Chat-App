//
//  File.swift
//  Chat App
//
//  Created by Kevin Li on 10/23/19.
//  Copyright © 2019 Kevin Li. All rights reserved.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var rootViewController: UINavigationController { get set }

    func start()
}
