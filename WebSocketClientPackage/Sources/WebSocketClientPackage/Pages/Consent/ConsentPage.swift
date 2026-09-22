//
//  ConsentPage.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import ComposableArchitecture
import DependenciesInterfaces
import SwiftUI

@Reducer
public struct ConsentReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
  }

  // MARK: - Action
  public enum Action {
    case showConsent
    case completed
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate: Sendable {
      case completedConsent
    }
  }

  @Dependency(\.consentInformation)
  private var consentInformation

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .showConsent:
        return .run(
          operation: { send in
            guard try await consentInformation.requestConsent() else {
              await send(.completed)
              return
            }
            try await consentInformation.load(false)
            await send(.completed)
          },
        )
      case .completed:
        return .send(.delegate(.completedConsent))
      case .delegate:
        return .none
      }
    }
  }
}

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
