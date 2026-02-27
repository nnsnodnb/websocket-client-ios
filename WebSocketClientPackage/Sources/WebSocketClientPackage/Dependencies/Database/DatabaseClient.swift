//
//  DatabaseClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/19.
//

import ComposableArchitecture
import CoreData
import Foundation
import SwiftData

@DependencyClient
public struct DatabaseClient: Sendable {
  // MARK: - Properties
  public var migrateCoreDataToSwiftData: @Sendable () async throws -> Void
  public var fetchHistories: @Sendable (Predicate<HistoryModel>?) async throws -> [HistoryEntity]
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

    @Dependency(\.modelContext.make)
    private var modelContext
    @Shared(.appStorage("key_migrated_to_swift_data"))
    private var migratedToSwiftData = false

    // MARK: - Initialize
    private init(inMemory: Bool = false) {
      guard let coreDataModelURL = #bundle.url(forResource: "Model", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: coreDataModelURL) else {
        Logger.fault("Wront Swift Package's manifest for CoreData.")
        fatalError("Wrong Swift Package's manifest for CoreData.")
      }
      self.container = NSPersistentContainer(name: "Model", managedObjectModel: model)
      if inMemory {
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
      }
      container.loadPersistentStores { storeDescription, error in
        guard let error else {
          #if DEBUG
          if let path = storeDescription.url?.path(percentEncoded: false) {
            Logger.debug("CoreData sqlite location: \(path)")
          }
          #endif
          return
        }
        Logger.fault("\(error)")
        fatalError("\(error)")
      }
      container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func migrateCoreDataToSwiftData() throws {
      guard !migratedToSwiftData else { return }
      let request = CDHistory.fetchRequest()
      request.sortDescriptors = [.init(key: "createdAt", ascending: true)]
      let histories = try container.viewContext.fetch(request)
      guard !histories.isEmpty else {
        $migratedToSwiftData.withLock { $0 = true }
        return
      }

      let context = modelContext()
      for oldHistory in histories {
        guard let id = oldHistory.id,
              let urlString = oldHistory.urlString,
              let createdAt = oldHistory.createdAt else { continue }
        // CDHistory → HistoryModel
        let newHistory = HistoryModel(
          id: id,
          urlString: urlString,
          isConnectionSuccess: oldHistory.isConnectionSuccess,
          createdAt: createdAt,
        )

        // CDMessage → MessageModel
        if let messages = oldHistory.messages as? Set<CDMessage> {
          for oldMessage in messages {
            guard let id = oldMessage.id,
                  let text = oldMessage.text,
                  let createdAt = oldMessage.createdAt else { continue }
            let newMessage = MessageModel(
              id: id,
              text: text,
              createdAt: createdAt,
              history: newHistory,
            )
          }
        }

        // CDCustomHeader → CustomHeaderModel
        if let customHeaders = oldHistory.customHeaders as? Set<CDCustomHeader> {
          for oldCustomHeader in customHeaders {
            guard let id = oldCustomHeader.id,
                  let name = oldCustomHeader.name,
                  let value = oldCustomHeader.value else { continue }
            let newCustomHeader = CustomHeaderModel(
              id: id,
              name: name,
              value: value,
              history: newHistory,
            )
          }
        }
      }

      if context.hasChanges {
        try context.save()
      }
      $migratedToSwiftData.withLock { $0 = true }
    }

    func fetchHistories(_ predicate: Predicate<HistoryModel>? = nil) throws -> [HistoryEntity] {
      let context = modelContext()
      let sortBy = [
        SortDescriptor<HistoryModel>(\.createdAt, order: .forward)
      ]
      let descriptor = FetchDescriptor<HistoryModel>(predicate: predicate, sortBy: sortBy)
      let models = try context.fetch(descriptor)
      let histories = models.map(convertToHistoryEntity(with:))
      return histories
    }

    func addHistory(_ history: HistoryEntity) throws {
      let context = modelContext()
      let model = convertToHistoryModel(with: history)
      context.insert(model)
      try context.save()
      Logger.info("Saved history")
    }

    func updateHistory(_ history: HistoryEntity) throws {
      let context = modelContext()
      guard let model = try getHistory(id: history.id, context: context) else { return }
      history.customHeaders
        .filter { customHeader in
          !model.customHeaders.contains(where: { $0.id == customHeader.id })
        }
        .forEach {
          let customHeaderModel = CustomHeaderModel(
            id: $0.id,
            name: $0.name,
            value: $0.value,
            history: model,
          )
          model.customHeaders.append(customHeaderModel)
        }
      history.messages
        .filter { message in
          !model.messages.contains(where: { $0.id == message.id })
        }
        .forEach {
          let messageModel = MessageModel(
            id: $0.id,
            text: $0.text,
            createdAt: $0.createdAt,
            history: model,
          )
          model.messages.append(messageModel)
        }
      model.isConnectionSuccess = history.isConnectionSuccess
      try context.save()
      Logger.info("Updated history")
    }

    func deleteHistory(_ history: HistoryEntity) throws {
      let context = modelContext()
      guard let model = try getHistory(id: history.id, context: context) else { return }
      context.delete(model)
      try context.save()
      Logger.info("Deleted history")
    }

    func deleteAllData() throws {
      do {
        let context = modelContext()
        try context.delete(model: HistoryModel.self)
        try context.save()
        Logger.info("Deleted all data")
      } catch {
        print(error)
        throw error
      }
    }

    // MARK: - Private method
    private func getHistory(id: UUID, context: ModelContext) throws -> HistoryModel? {
      let predicate = #Predicate<HistoryModel> { $0.id == id }
      let descriptor = FetchDescriptor<HistoryModel>(predicate: predicate, sortBy: [])
      let model = try context.fetch(descriptor).first
      return model
    }

    private func convertToHistoryEntity(with history: HistoryModel) -> sending HistoryEntity {
      let customHeaders = history.customHeaders.map {
        var customHeader = CustomHeaderEntity(id: $0.id)
        customHeader.setName($0.name)
        customHeader.setValue($0.value)
        return customHeader
      }
      let messages = history.messages.map {
        MessageEntity(id: $0.id, text: $0.text, createdAt: $0.createdAt)
      }
      return HistoryEntity(
        id: history.id,
        url: URL(string: history.urlString)!,
        customHeaders: customHeaders,
        messages: messages,
        isConnectionSuccess: history.isConnectionSuccess,
        createdAt: history.createdAt,
      )
    }

    private func convertToHistoryModel(with history: HistoryEntity) -> HistoryModel {
      let model = HistoryModel(
        id: history.id,
        urlString: history.url.absoluteString,
        isConnectionSuccess: history.isConnectionSuccess,
      )
      model.customHeaders = history.customHeaders
        .map {
          let customHeaderModel = CustomHeaderModel(
            id: $0.id,
            name: $0.name,
            value: $0.value,
            history: model,
          )
          return customHeaderModel
        }
      model.messages = history.messages
        .map {
          let messageModel = MessageModel(
            id: $0.id,
            text: $0.text,
            createdAt: $0.createdAt,
            history: model,
          )
          return messageModel
        }
      return model
    }
  }
}

// MARK: - DependencyKey
extension DatabaseClient: DependencyKey {
  public static let liveValue: Self = .init(
    migrateCoreDataToSwiftData: { try await DatabaseActor.shared.migrateCoreDataToSwiftData() },
    fetchHistories: { try await DatabaseActor.shared.fetchHistories($0) },
    addHistory: { try await DatabaseActor.shared.addHistory($0) },
    updateHistory: { try await DatabaseActor.shared.updateHistory($0) },
    deleteHistory: { try await DatabaseActor.shared.deleteHistory($0) },
    deleteAllData: { try await DatabaseActor.shared.deleteAllData() },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var database: DatabaseClient {
    get {
      self[DatabaseClient.self]
    }
    set {
      self[DatabaseClient.self] = newValue
    }
  }
}
