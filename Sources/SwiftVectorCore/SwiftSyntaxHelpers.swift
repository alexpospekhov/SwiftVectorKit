import Foundation

/// Swift-aware code tokenization and identifier splitting helpers.
/// Preprocesses compound identifiers (camelCase, PascalCase, snake_case) and doc comments
/// to produce high-density semantic representations for vector embeddings.
public struct SwiftSyntaxHelpers: Sendable {
    public init() {}

    /// Splits a compound Swift identifier into constituent natural language words.
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
}
