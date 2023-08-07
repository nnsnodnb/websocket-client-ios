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

public struct DatabaseClient {
    // MARK: - Properties
    public var fetchHistories: @Sendable (NSPredicate?) async throws -> [HistoryEntity]
    public var addHistory: @Sendable (HistoryEntity) async throws -> Void
    public var updateHistory: @Sendable (HistoryEntity) async throws -> Void
    public var deleteHistory: @Sendable (HistoryEntity) async throws -> Void
    public var deleteAllData: @Sendable () async throws -> Void
}

public extension DatabaseClient {
    final actor DatabaseActor: GlobalActor {
        // MARK: - Properties
        public static let shared = DatabaseActor()

        fileprivate static let preview = DatabaseActor(inMemory: true)
        fileprivate static let test = DatabaseActor(inMemory: true)

        fileprivate let container: NSPersistentContainer

        // MARK: - Initialize
        private init(inMemory: Bool = false) {
            guard let coreDataModelURL = Bundle.module.url(forResource: "Model", withExtension: "momd"),
                  let model = NSManagedObjectModel(contentsOf: coreDataModelURL) else {
                fatalError("Wrong Swift Package's manifest for CoreData.")
            }
            self.container = NSPersistentContainer(name: "Model", managedObjectModel: model)
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

        func fetchHistories(_ predicate: NSPredicate? = nil) throws -> [HistoryEntity] {
            let request = CDHistory.fetchRequest()
            request.sortDescriptors = [.init(key: "createdAt", ascending: true)]
            request.predicate = predicate
            return try container.viewContext.fetch(request)
                .map(convertToHistoryEntity(with:))
        }

        func addHistory(_ history: HistoryEntity) throws {
            container.viewContext.insert(convertToCDHistory(with: history))
            guard container.viewContext.hasChanges else { return }
            try container.viewContext.save()
        }

        func updateHistory(_ history: HistoryEntity) throws {
            guard let entity = try getHistory(id: history.id) else { return }
            let cdCustomHeaders = entity.customHeaders?.allObjects as? [CDCustomHeader] ?? []
            history.customHeaders
                .filter { customHeader in
                    !cdCustomHeaders.contains(where: { $0.id == customHeader.id })
                }
                .map { convertToCDCustomHeader(with: $0, of: entity) }
                .forEach(entity.addToCustomHeaders(_:))
            let cdMessages = entity.messages?.allObjects as? [CDMessage] ?? []
            history.messages
                .filter { message in
                    !cdMessages.contains(where: { $0.id == message.id })
                }
                .map { convertToCDMessage(with: $0, of: entity) }
                .forEach(entity.addToMessages(_:))
            entity.isConnectionSuccess = history.isConnectionSuccess
            guard container.viewContext.hasChanges else { return }
            try container.viewContext.save()
        }

        func deleteHistory(_ history: HistoryEntity) throws {
            guard let entity = try getHistory(id: history.id) else { return }
            container.viewContext.delete(entity)
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

        // MARK: - Private method
        private func getHistory(id: UUID) throws -> CDHistory? {
            let request = CDHistory.fetchRequest()
            let predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.predicate = predicate
            return try container.viewContext.fetch(request).first
        }

        private func convertToHistoryEntity(with history: CDHistory) -> HistoryEntity {
            let customHeaders = (history.customHeaders?.allObjects as? [CDCustomHeader] ?? []).map {
                var entity = CustomHeaderEntity(id: $0.id!)
                entity.setName($0.name!)
                entity.setValue($0.value!)
                return entity
            }
            let messages = (history.messages?.allObjects as? [CDMessage] ?? []).map {
                MessageEntity(id: $0.id!, text: $0.text!, createdAt: $0.createdAt!)
            }
            return HistoryEntity(
                id: history.id!,
                url: URL(string: history.urlString!)!,
                customHeaders: customHeaders,
                messages: messages,
                isConnectionSuccess: history.isConnectionSuccess,
                createdAt: history.createdAt!
            )
        }

        private func convertToCDHistory(with history: HistoryEntity) -> CDHistory {
            let entity = CDHistory(context: container.viewContext)
            entity.id = history.id
            entity.urlString = history.url.absoluteString
            let customHeaders = history.customHeaders.map { convertToCDCustomHeader(with: $0, of: entity) }
            entity.customHeaders = .init(array: customHeaders)
            let messages = history.messages.map { convertToCDMessage(with: $0, of: entity) }
            entity.messages = .init(array: messages)
            entity.isConnectionSuccess = history.isConnectionSuccess
            entity.createdAt = history.createdAt
            return entity
        }

        private func convertToCDCustomHeader(with customHeader: CustomHeaderEntity, of history: CDHistory) -> CDCustomHeader {
            let entity = CDCustomHeader(context: container.viewContext)
            entity.id = customHeader.id
            entity.name = customHeader.name
            entity.value = customHeader.value
            entity.history = history
            return entity
        }

        private func convertToCDMessage(with message: MessageEntity, of history: CDHistory) -> CDMessage {
            let entity = CDMessage(context: container.viewContext)
            entity.id = message.id
            entity.text = message.text
            entity.createdAt = message.createdAt
            entity.history = history
            return entity
        }
    }
}

// MARK: - DependencyKey
extension DatabaseClient: DependencyKey {
    public static var liveValue = Self(
        fetchHistories: { try await DatabaseActor.shared.fetchHistories($0) },
        addHistory: { try await DatabaseActor.shared.addHistory($0) },
        updateHistory: { try await DatabaseActor.shared.updateHistory($0) },
        deleteHistory: { try await DatabaseActor.shared.deleteHistory($0) },
        deleteAllData: { try await DatabaseActor.shared.deleteAllData() }
    )

    public static var previewValue = Self(
        fetchHistories: { _ in [] },
        addHistory: { _ in },
        updateHistory: { _ in },
        deleteHistory: { _ in },
        deleteAllData: {}
    )

    public static var testValue = Self(
        fetchHistories: unimplemented("\(Self.self).fetchHistories"),
        addHistory: unimplemented("\(Self.self).addHistory"),
        updateHistory: unimplemented("\(Self.self).updateHistory"),
        deleteHistory: unimplemented("\(Self.self).deleteHistory"),
        deleteAllData: unimplemented("\(Self.self).deleteAllData")
    )
}
