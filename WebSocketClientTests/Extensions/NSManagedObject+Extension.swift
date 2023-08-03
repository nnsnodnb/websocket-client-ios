//
//  NSManagedObject+Extension.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/08/03.
//

import CoreData
import Foundation
@testable import WebSocketClient

extension NSManagedObject {
    static func insertNewObject(managedObjectContext: NSManagedObjectContextProtocol) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Self.self),
                                                   into: managedObjectContext as! NSManagedObjectContext) as! Self
    }
}
