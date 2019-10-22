//
//  UIView+Additions.swift
//  Chat App
//
//  Created by Kevin Li on 10/22/19.
//  Copyright © 2019 Kevin Li. All rights reserved.
//

import UIKit

extension UIView {
  
  func smoothRoundCorners(to radius: CGFloat) {
    let maskLayer = CAShapeLayer()
    maskLayer.path = UIBezierPath(
      roundedRect: bounds,
      cornerRadius: radius
    ).cgPath
    
    layer.mask = maskLayer
  }
  
}
