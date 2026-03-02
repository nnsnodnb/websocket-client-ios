//
//  SwiftUIView.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import SwiftUI

public struct LicenseListPage: View {
  // MARK: - Properties
  let store: StoreOf<LicenseListReducer>

  // MARK: - Body
  public var body: some View {
    list
      .navigationTitle(.infoSectionFourthTitleLicenses)
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
