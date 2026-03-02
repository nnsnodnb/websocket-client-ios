//
//  UIDevice+Extensions.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/02/13.
//

import UIKit

@MainActor
extension UIDevice {
  var isLiquidEffectEnabled: Bool {
    if #available(iOS 26.0, *) {
      true
    } else {
      false
    }
  }
}
