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
    var managedObjectContext: @Sendable () -> NSManagedObjectContext
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

        func context() -> NSManagedObjectContext {
            return container.viewContext
        }

        func fetchHistories(_ predicate: NSPredicate? = nil) throws -> [CDHistory] {
            let request = CDHistory.fetchRequest()
            request.sortDescriptors = [.init(key: "createdAt", ascending: true)]
            request.predicate = predicate
            return try container.viewContext.fetch(request)
        }

        func getHistory(id: Int) throws -> CDHistory? {
            let request = CDHistory.fetchRequest()
            let predicate = NSPredicate(format: "id == %@", id)
            request.predicate = predicate
            return try container.viewContext.fetch(request).first
        }

        func addHistory(_ history: CDHistory) throws {
            container.viewContext.insert(history)
            guard container.viewContext.hasChanges else { return }
            try container.viewContext.save()
        }

        func updateHistory(_ history: CDHistory) throws {
            guard container.viewContext.hasChanges else { return }
            try container.viewContext.save()
        }

        func deleteHistory(_ history: CDHistory) throws {
            container.viewContext.delete(history)
            guard container.viewContext.hasChanges else { return }
            try container.viewContext.save()
        }

        func deleteAllData() throws {
            let request = CDHistory.fetchRequest()
            let histories = try container.viewContext.fetch(request)
            guard !histories.isEmpty else { return }
            histories.forEach(container.viewContext.delete)
            guard container.viewContext.hasChanges else { return }
            try container.viewContext.save()
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
