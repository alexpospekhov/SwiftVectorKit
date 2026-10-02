import Foundation

/// Compiler-compatible diagnostic warning or error to be emitted into Xcode's Issue Navigator.
public struct DiagnosticWarning: Sendable, Codable, Equatable, CustomStringConvertible {
    public let filePath: String
    public let line: Int
    public let column: Int
    public let severity: Severity
    public let message: String

    public enum Severity: String, Sendable, Codable, Equatable {
        case note
        case warning
        case error
    }

    public init(
        filePath: String,
        line: Int,
        column: Int = 1,
        severity: Severity = .warning,
        message: String
    ) {
        self.filePath = filePath
        self.line = line
        self.column = column
        self.severity = severity
        self.message = message
    }

    /// Formats the diagnostic into the standard Clang/Swift compiler format recognized by Xcode:
    /// `file:line:column: warning: Message`
    public var description: String {
        "\(filePath):\(line):\(column): \(severity.rawValue): [SwiftVectorKit] \(message)"
    }
}
