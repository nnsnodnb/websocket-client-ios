//
//  AppDelegate.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import FirebaseCore
import RealmSwift
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Realm.registerRealmables([CustomHeader.self, History.self, Message.self])
        RealmMigrations.migration()
        #if DEBUG
        print(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "Unknown realm file")
        #endif
        FirebaseApp.configure()
        return true
    }
}
