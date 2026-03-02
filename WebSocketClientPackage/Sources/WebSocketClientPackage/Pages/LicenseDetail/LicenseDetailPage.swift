//
//  LicenseDetailPage.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import SwiftUI

public struct LicenseDetailPage: View {
  // MARK: - Properties
  public let license: LicensesPlugin.License

  // MARK: - Body
  public var body: some View {
    Form {
      if let licenseText = license.licenseText {
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
    .navigationTitle(license.name)
  }
}

#Preview {
  LicenseDetailPage(
    license: .init(
      id: "dummy",
      name: "Dummy",
      licenseText: "Dummy license text",
    )
  )
}
