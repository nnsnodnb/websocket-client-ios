//
//  LicenseDetailPage.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct LicenseDetailReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public let license: LicensesPlugin.License
  }

  // MARK: - Action
  public enum Action {
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}

public struct LicenseDetailPage: View {
  // MARK: - Properties
  public let store: StoreOf<LicenseDetailReducer>

  // MARK: - Body
  public var body: some View {
    Form {
      if let licenseText = store.license.licenseText {
        ScrollView {
          Text(licenseText)
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
      }
    }
    .formStyle(.columns)
    .navigationTitle(store.license.name)
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

#Preview {
  LicenseDetailPage(
    store: .init(
      initialState: LicenseDetailReducer.State(
        license: .init(
          id: "dummy",
          name: "Dummy",
          licenseText: "Dummy license text",
        )
      ),
      reducer: {
        LicenseDetailReducer()
      },
    ),
  )
}
