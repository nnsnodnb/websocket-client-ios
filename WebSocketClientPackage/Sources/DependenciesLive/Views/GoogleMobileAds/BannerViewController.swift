//
//  BannerViewController.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/25.
//

import GoogleMobileAds
import UIKit

public final class BannerViewController: UIViewController {
  // MARK: - Properties
  private let bannerView = BannerView()
  private let adUnitID: String

  public var onAdSizeChange: ((CGSize) -> Void)?
  public var preferredSize: CGSize {
    CGSize(width: view.bounds.width, height: bannerView.adSize.size.height)
  }

  private var lastWidth: CGFloat = 0

  // MARK: - Initialize
  public init(adUnitID: String) {
    self.adUnitID = adUnitID
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("Plase use init(adUnitID:String)")
  }

  // MARK: - Life Cycle
  override public func viewDidLoad() {
    super.viewDidLoad()
    bannerView.adUnitID = adUnitID
    bannerView.rootViewController = self
    bannerView.delegate = self
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bannerView)

    NSLayoutConstraint.activate([
      bannerView.topAnchor.constraint(equalTo: view.topAnchor),
      bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  override public func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    loadBannerIfNeeded(for: view.bounds.size)
  }

  override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(
      alongsideTransition: { [weak self] _ in
        self?.loadBannerIfNeeded(for: size)
      },
    )
  }

  private func loadBannerIfNeeded(for size: CGSize) {
    guard size.width > 0, size.width != lastWidth else { return }
    lastWidth = size.width

    bannerView.adSize = largeAnchoredAdaptiveBanner(width: size.width)
    bannerView.load(Request())
  }
}

// MARK: - BannerViewDelegate
extension BannerViewController: BannerViewDelegate {
  public func bannerViewDidReceiveAd(_ bannerView: BannerView) {
    onAdSizeChange?(preferredSize)
  }
}
