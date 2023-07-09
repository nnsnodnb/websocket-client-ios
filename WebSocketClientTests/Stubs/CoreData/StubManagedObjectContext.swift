//
//  StubManagedObjectContext.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/07/09.
//

import CoreData
import Foundation
@testable import WebSocketClient

final class StubManagedObjectContext: NSManagedObjectContextProtocol {
    var automaticallyMergesChangesFromParent = true
    var hasChanges = true

    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T: NSFetchRequestResult {
        return []
    }

    func insert(_ object: NSManagedObject) {
    }

    func delete(_ object: NSManagedObject) {
    }

    func save() throws {
    }
}
