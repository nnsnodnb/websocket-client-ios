//
//  LicenseListReducer.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct LicenseListReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public let licenses: IdentifiedArrayOf<LicensesPlugin.License> = .init(uniqueElements: LicensesPlugin.licenses)
  }

  // MARK: - Action
  public enum Action: Equatable, Sendable {
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}
