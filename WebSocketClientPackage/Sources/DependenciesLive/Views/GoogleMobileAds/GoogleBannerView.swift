//
//  GoogleBannerView.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/21.
//

import Dependencies
import DependenciesInterfaces
import GoogleMobileAds
import SwiftUI

public struct GoogleBannerView: UIViewControllerRepresentable {
  // MARK: - Properties
  public let adUnitID: String

  @Binding public var adHeight: CGFloat

  public func makeUIViewController(context: Context) -> BannerViewController {
    let viewController = BannerViewController(adUnitID: adUnitID)
    viewController.onAdSizeChange = { @MainActor size in
      adHeight = size.height
    }
    return viewController
  }

  public func updateUIViewController(_ uiViewController: BannerViewController, context: Context) {
  }

  public func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: BannerViewController, context: Context) -> CGSize? {
    guard let width = proposal.width else { return nil }
    uiViewController.view.layoutIfNeeded()
    return .init(width: width, height: uiViewController.preferredSize.height)
  }
}
