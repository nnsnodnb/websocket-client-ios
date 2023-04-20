//
//  DatabaseClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/19.
//

import ComposableArchitecture
import Foundation
import Unrealm
import XCTestDynamicOverlay

struct DatabaseClient {
    // MARK: - Properties
    var fetchHistories: @Sendable () async throws -> [History]
    var getHistory: @Sendable (Int) async throws -> History?
}

extension DatabaseClient {
    final actor DatabaseActor: GlobalActor {
        // MARK: - Properties
        static let shared = DatabaseActor()

        // MARK: - Initialize
        init() {
            Realm.registerRealmables([History.self])
        }

        func fetchHistories() throws -> [History] {
            let realm = try Realm()
            let results = realm.objects(History.self)
            return Array(results)
        }

        func getHistory(id: Int) throws -> History? {
            let realm = try Realm()
            let object = realm.object(ofType: History.self, forPrimaryKey: id)
            return object
        }
    }
}

// MARK: - DependencyKey
extension DatabaseClient: DependencyKey {
    static var liveValue = Self(
        fetchHistories: { try await DatabaseActor.shared.fetchHistories() },
        getHistory: { try await DatabaseActor.shared.getHistory(id: $0) }
    )

    static var testValue = Self(
        fetchHistories: unimplemented("\(Self.self).fetchHistories"),
        getHistory: unimplemented("\(Self.self).getHistory")
    )
}
