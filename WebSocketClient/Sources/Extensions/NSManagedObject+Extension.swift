//
//  NSManagedObject+Extension.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/07/09.
//

import CoreData

extension NSManagedObject {
    convenience init(context: NSManagedObjectContextProtocol) {
        self.init(context: context)
    }
}
