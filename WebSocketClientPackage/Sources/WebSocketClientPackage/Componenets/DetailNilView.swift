//
//  DetailNilView.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/24.
//

import SwiftUI

public struct DetailNilView: View {
  // MARK: - Properties
  public let text: LocalizedStringResource

  public var body: some View {
    Text(text)
      .font(.system(size: 20))
      .foregroundStyle(Color.gray)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .backgroundStyle(Color(UIColor.systemGroupedBackground))
  }
}
