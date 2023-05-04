//
//  RealmMigrations.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/05.
//

import Foundation
import RealmSwift
import Unrealm

struct RealmMigrations {
    static func migration() {
        Realm.Configuration.defaultConfiguration = .init(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // Add ID in CustomHeader
                    migration.enumerateObjects(ofType: CustomHeader.rlmClassName()) { _, newObject in
                        newObject?["id"] = UUID().uuidString
                    }
                }
            }
        )
    }
}
