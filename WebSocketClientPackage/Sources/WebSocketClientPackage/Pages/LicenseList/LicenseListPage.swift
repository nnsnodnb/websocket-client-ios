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
  public enum Action: Equatable, Sendable {
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    EmptyReducer()
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
        NavigationLink(
          destination: {
            LicenseDetailPage(license: license)
          },
          label: {
            Text(license.name)
              .foregroundStyle(Color(.label))
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        )
      }
    }
  }
}

#Preview {
  LicenseListPage(
    store: .init(
      initialState: LicenseListReducer.State(),
      reducer: {
        LicenseListReducer()
      },
    )
  )
}
