//
//  NSManagedObjectContextProtocol.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/07/09.
//

import CoreData

public protocol NSManagedObjectContextProtocol {
    var automaticallyMergesChangesFromParent: Bool { get set }
    var hasChanges: Bool { get }

    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T: NSFetchRequestResult
    func insert(_ object: NSManagedObject)
    func delete(_ object: NSManagedObject)
    func save() throws
}
