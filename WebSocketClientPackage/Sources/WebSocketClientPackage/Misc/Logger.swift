//
//  Logger.swift
//
//
//  Created by Yuya Oka on 2023/10/01.
//

import Foundation
import os

final actor Logger {
    // MARK: - Properties
    private static let _logger = os.Logger(subsystem: "moe.nnsnodnb.WebSocketClient", category: "Package")

    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        _logger.debug("👻 \(message)\(Self.joinFileFunctionLine(file: file, function: function, line: line))")
        #endif
    }

    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        _logger.info("🤖 \(message)\(Self.joinFileFunctionLine(file: file, function: function, line: line))")
        #endif
    }

    static func notice(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        _logger.notice("🤔 \(message)\(Self.joinFileFunctionLine(file: file, function: function, line: line))")
        #endif
    }

    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        _logger.warning("🚧 \(message)\(Self.joinFileFunctionLine(file: file, function: function, line: line))")
        #endif
    }

    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        _logger.error("🚨 \(message)\(Self.joinFileFunctionLine(file: file, function: function, line: line))")
        #endif
    }

    static func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        _logger.critical("🔥 \(message)\(Self.joinFileFunctionLine(file: file, function: function, line: line))")
        #endif
    }

    static func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        _logger.fault("💣 \(message)\(Self.joinFileFunctionLine(file: file, function: function, line: line))")
        #endif
    }
}

// MARK: - Private method
private extension Logger {
    static func joinFileFunctionLine(file: String, function: String, line: Int) -> String {
        return "\n📁 File: \(file)\n📝 Function: \(function) L.\(line)"
    }
}
