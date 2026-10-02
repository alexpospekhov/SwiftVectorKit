import Foundation
import SwiftVectorCore

/// Swift-aware code tokenizer and identifier splitter.
/// Handles Swift conventions (camelCase, PascalCase, snake_case, doc comments, markdown tags).
public struct PureSwiftTokenizer: Sendable {
    public init() {}

    /// Splits a compound Swift identifier into constituent English words.
    /// Examples:
    /// - `AccelerateSIMDDistance` -> `["Accelerate", "SIMD", "Distance"]`
    /// - `cosineSimilarity` -> `["cosine", "Similarity"]`
    /// - `isApproachingLimit` -> `["is", "Approaching", "Limit"]`
    /// - `HTMLParser` -> `["HTML", "Parser"]`
    public static func splitIdentifier(_ name: String) -> [String] {
        var words: [String] = []
        var current = ""
        let chars = Array(name)

        for i in 0..<chars.count {
            let c = chars[i]
            if c == "_" || c == "-" {
                if !current.isEmpty { words.append(current); current = "" }
                continue
            }

            if c.isUppercase {
                let prevIsLower = (i > 0 && chars[i-1].isLowercase)
                let nextIsLower = (i + 1 < chars.count && chars[i+1].isLowercase)
                let prevIsUpper = (i > 0 && chars[i-1].isUppercase)

                if prevIsLower || (prevIsUpper && nextIsLower && current.count > 1) {
                    if !current.isEmpty { words.append(current); current = "" }
                }
            }

            current.append(c)
        }
        if !current.isEmpty { words.append(current) }
        return words
    }

    /// Cleans and normalizes Swift documentation comments (`/// ...`).
    /// Removes markdown comment prefixes and parameter/return callouts.
    public static func cleanDocComment(_ raw: String) -> String {
        let lines = raw.components(separatedBy: "\n")
        var cleanLines: [String] = []

        for line in lines {
            var trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("///") {
                trimmed = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
            } else if trimmed.hasPrefix("//") {
                trimmed = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
            }

            // Strip Swift doc callout prefixes
            if trimmed.hasPrefix("- Parameter") || trimmed.hasPrefix("- Parameters:") {
                trimmed = trimmed.replacingOccurrences(of: "- Parameter", with: "Parameter")
            } else if trimmed.hasPrefix("- Returns:") {
                trimmed = trimmed.replacingOccurrences(of: "- Returns:", with: "Returns:")
            } else if trimmed.hasPrefix("- Throws:") {
                trimmed = trimmed.replacingOccurrences(of: "- Throws:", with: "Throws:")
            }

            if !trimmed.isEmpty {
                cleanLines.append(trimmed)
            }
        }
        return cleanLines.joined(separator: " ")
    }

    /// Fast token ID conversion fallback.
    public func tokenize(_ text: String) -> [Int32] {
        text.utf8.prefix(512).map { Int32($0) }
    }
}
