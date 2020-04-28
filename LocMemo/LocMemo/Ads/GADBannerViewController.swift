//
//  GADBannerViewController.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/28/20.
//  Copyright © 2020 x. All rights reserved.
//

import GoogleMobileAds
import SwiftUI

struct GADBannerViewController: UIViewControllerRepresentable {

    #if targetEnvironment(simulator)
    let adUnitID = "ca-app-pub-3940256099942544/2934735716"
    #else
    let adUnitID = "xxx"
    #endif

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = viewController

        viewController.view.addSubview(bannerView)
        viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeBanner.size)

        bannerView.load(GADRequest())

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // do nothing.
    }
}
