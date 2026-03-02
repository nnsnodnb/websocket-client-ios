//
//  ConsentPage.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import ComposableArchitecture
import SwiftUI

public struct ConsentPage: View {
  // MARK: - Properties
  let store: StoreOf<ConsentReducer>

  // MARK: - Body
  public var body: some View {
    Color(UIColor.systemBackground.withAlphaComponent(0.000001))
      .onAppear {
        store.send(.showConsent)
      }
  }
}

#Preview {
  ConsentPage(
    store: .init(
      initialState: ConsentReducer.State(),
      reducer: {
        ConsentReducer()
      },
    ),
  )
}
