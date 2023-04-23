//
//  AppDelegate.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import RealmSwift
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Realm.registerRealmables([History.self, Message.self])
        #if DEBUG
        print(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "Unknown realm file")
        #endif
        return true
    }
}
