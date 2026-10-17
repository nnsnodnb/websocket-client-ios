//
//  SwiftUIView.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct LicenseListReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public let licenses: IdentifiedArrayOf<LicensesPlugin.License> = .init(uniqueElements: LicensesPlugin.licenses)
  }

  // MARK: - Action
  public enum Action {
    case pushLicenseDetail(LicensesPlugin.License)
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case pushLicenseDetail(LicensesPlugin.License)
    }
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case let .pushLicenseDetail(license):
        return .send(.delegate(.pushLicenseDetail(license)))
      case .delegate:
        return .none
      }
    }
  }
}

public struct LicenseListPage: View {
  // MARK: - Properties
  let store: StoreOf<LicenseListReducer>

  // MARK: - Body
  public var body: some View {
    list
      .navigationTitle(.infoSectionFourthTitleLicenses)
      .modifier {
        if #available(iOS 26.0, *) {
          $0
            .scrollEdgeEffectStyle(.soft, for: .top)
        } else {
          $0
        }
      }
  }
}

// MARK: - Private method
@MainActor
private extension LicenseListPage {
  var list: some View {
    List {
      ForEach(store.licenses) { license in
        Button(
          action: {
            store.send(.pushLicenseDetail(license))
          },
          label: {
            HStack {
              HStack(spacing: 12) {
                Text(license.name)
                  .foregroundColor(Color(.label))
              }
              Spacer()
              Image(systemSymbol: .chevronRight)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .opacity(0.5)
            }
          }
        )
      }
    }
  }
}

#Preview {
  NavigationStack(
    root: {
      LicenseListPage(
        store: .init(
          initialState: LicenseListReducer.State(),
          reducer: {
            LicenseListReducer()
          },
        )
      )
    },
  )
}
