//
//  View+Extension.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/19.
//

import SwiftUI

extension View {
  func modifier(@ViewBuilder _ closure: (Self) -> some View) -> some View {
    closure(self)
  }
}
