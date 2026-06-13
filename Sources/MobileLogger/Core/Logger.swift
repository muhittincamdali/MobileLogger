import Foundation
import os.log

/// A thread-safe wrapper for mutable state
public final class Locked<T>: @unchecked Sendable {
    private let lock = NSLock()
    private var value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func withLock<U>(_ body: (inout T) throws -> U) rethrows -> U {
        lock.lock()
        defer { lock.unlock() }
        return try body(&value)
    }
}

/// The official logging engine for the 'Endless March' ecosystem.
public actor MobileLogger {
    public static let shared = MobileLogger()
    
    private let systemLogger = Logger(subsystem: "com.mobilelogger.core", category: "General")
    
    private init() {}
    
    public func log(_ message: String, level: LogLevel = .info) {
        let type: OSLogType
        switch level {
        case .debug: type = .debug
        case .info: type = .info
        case .error: type = .error
        case .fault: type = .fault
        }
        systemLogger.log(level: type, "\(message)")
    }
}

public enum LogLevel: String, Sendable {
    case debug
    case info
    case error
    case fault
}
