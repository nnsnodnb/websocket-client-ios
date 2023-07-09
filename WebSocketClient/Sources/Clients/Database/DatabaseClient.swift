//
//  DatabaseClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/19.
//

import ComposableArchitecture
import CoreData
import Foundation
import XCTestDynamicOverlay

struct DatabaseClient {
    // MARK: - Properties
    var managedObjectContext: @Sendable () -> NSManagedObjectContextProtocol
    var fetchHistories: @Sendable (NSPredicate?) async throws -> [CDHistory]
    var getHistory: @Sendable (Int) async throws -> CDHistory?
    var addHistory: @Sendable (CDHistory) async throws -> Void
    var updateHistory: @Sendable (CDHistory) async throws -> Void
    var deleteHistory: @Sendable (CDHistory) async throws -> Void
    var deleteAllData: @Sendable () async throws -> Void
}

extension DatabaseClient {
    final actor DatabaseActor: GlobalActor {
        // MARK: - Properties
        static let shared = DatabaseActor()

        fileprivate static let preview = DatabaseActor(inMemory: true)

        fileprivate let container: NSPersistentContainer

        // MARK: - Initialize
        private init(inMemory: Bool = false) {
            self.container = NSPersistentContainer(name: "Model")
            if inMemory {
                container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            }
            container.loadPersistentStores { storeDescription, error in
                guard let error else {
                    #if Debug
                    print("CoreData sqlite location: \(storeDescription.url?.path(percentEncoded: false) ?? "")")
                    #endif
                    return
                }
                fatalError("\(error)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }

        func context() -> NSManagedObjectContextProtocol {
            return container.viewContext
        }

        func fetchHistories(_ predicate: NSPredicate? = nil) throws -> [CDHistory] {
            let request = CDHistory.fetchRequest()
            request.sortDescriptors = [.init(key: "createdAt", ascending: true)]
            request.predicate = predicate
            return try context().fetch(request)
        }

        func getHistory(id: Int) throws -> CDHistory? {
            let request = CDHistory.fetchRequest()
            let predicate = NSPredicate(format: "id == %@", id)
            request.predicate = predicate
            return try context().fetch(request).first
        }

        func addHistory(_ history: CDHistory) throws {
            context().insert(history)
            guard context().hasChanges else { return }
            try context().save()
        }

        func updateHistory(_ history: CDHistory) throws {
            guard context().hasChanges else { return }
            try context().save()
        }

        func deleteHistory(_ history: CDHistory) throws {
            context().delete(history)
            guard context().hasChanges else { return }
            try context().save()
        }

        func deleteAllData() throws {
            let request = CDHistory.fetchRequest()
            let histories = try context().fetch(request)
            guard !histories.isEmpty else { return }
            histories.forEach(context().delete)
            guard context().hasChanges else { return }
            try context().save()
        }
    }
}

// MARK: - DependencyKey
extension DatabaseClient: DependencyKey {
    static var liveValue = Self(
        managedObjectContext: { DatabaseActor.shared.container.viewContext },
        fetchHistories: { try await DatabaseActor.shared.fetchHistories($0) },
        getHistory: { try await DatabaseActor.shared.getHistory(id: $0) },
        addHistory: { try await DatabaseActor.shared.addHistory($0) },
        updateHistory: { try await DatabaseActor.shared.updateHistory($0) },
        deleteHistory: { try await DatabaseActor.shared.deleteHistory($0) },
        deleteAllData: { try await DatabaseActor.shared.deleteAllData() }
    )

    static var previewValue = Self(
        managedObjectContext: { DatabaseActor.preview.container.viewContext },
        fetchHistories: { _ in [] },
        getHistory: { _ in nil },
        addHistory: { _ in },
        updateHistory: { _ in },
        deleteHistory: { _ in },
        deleteAllData: {}
    )

    static var testValue = Self(
        managedObjectContext: unimplemented("\(Self.self).managedObjectContext"),
        fetchHistories: unimplemented("\(Self.self).fetchHistories"),
        getHistory: unimplemented("\(Self.self).getHistory"),
        addHistory: unimplemented("\(Self.self).addHistory"),
        updateHistory: unimplemented("\(Self.self).updateHistory"),
        deleteHistory: unimplemented("\(Self.self).deleteHistory"),
        deleteAllData: unimplemented("\(Self.self).deleteAllData")
    )
}
