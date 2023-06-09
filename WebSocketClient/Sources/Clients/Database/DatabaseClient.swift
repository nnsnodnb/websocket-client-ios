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
    var fetchHistories: @Sendable ((Results<History>) -> Results<History>) async throws -> [History]
    var getHistory: @Sendable (Int) async throws -> History?
    var addHistory: @Sendable (History) async throws -> Void
    var updateHistory: @Sendable (History) async throws -> Void
    var deleteHistory: @Sendable (History) async throws -> Void
    var deleteAllData: @Sendable () async throws -> Void
}

extension DatabaseClient {
    final actor DatabaseActor: GlobalActor {
        // MARK: - Properties
        static let shared = DatabaseActor()

        func fetchHistories(operation: (Results<History>) -> Results<History>) throws -> [History] {
            let realm = try Realm()
            let results = realm.objects(History.self)
            return Array(operation(results))
        }

        func getHistory(id: Int) throws -> History? {
            let realm = try Realm()
            let object = realm.object(ofType: History.self, forPrimaryKey: id)
            return object
        }

        func addHistory(_ history: History) throws {
            let realm = try Realm()
            try realm.write {
                realm.add(history)
            }
        }

        func updateHistory(_ history: History) throws {
            let realm = try Realm()
            try realm.write {
                realm.add(history, update: .modified)
            }
        }

        func deleteHistory(_ history: History) throws {
            let realm = try Realm()
            try realm.write {
                realm.delete(history.messages)
                realm.delete(history.customHeaders)
                realm.delete(history)
            }
        }

        func deleteAllData() throws {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        }
    }
}

// MARK: - DependencyKey
extension DatabaseClient: DependencyKey {
    static var liveValue = Self(
        fetchHistories: { try await DatabaseActor.shared.fetchHistories(operation: $0) },
        getHistory: { try await DatabaseActor.shared.getHistory(id: $0) },
        addHistory: { try await DatabaseActor.shared.addHistory($0) },
        updateHistory: { try await DatabaseActor.shared.updateHistory($0) },
        deleteHistory: { try await DatabaseActor.shared.deleteHistory($0) },
        deleteAllData: { try await DatabaseActor.shared.deleteAllData() }
    )

    static var previewValue = Self(
        fetchHistories: { _ in [] },
        getHistory: { _ in nil },
        addHistory: { _ in },
        updateHistory: { _ in },
        deleteHistory: { _ in },
        deleteAllData: {}
    )

    static var testValue = Self(
        fetchHistories: unimplemented("\(Self.self).fetchHistories"),
        getHistory: unimplemented("\(Self.self).getHistory"),
        addHistory: unimplemented("\(Self.self).addHistory"),
        updateHistory: unimplemented("\(Self.self).updateHistory"),
        deleteHistory: unimplemented("\(Self.self).deleteHistory"),
        deleteAllData: unimplemented("\(Self.self).deleteAllData")
    )
}
