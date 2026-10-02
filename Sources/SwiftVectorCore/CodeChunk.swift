import Foundation

/// Canonical semantic AST chunk extracted from source code.
public struct CodeChunk: Identifiable, Sendable, Codable, Equatable {
    public let id: String
    public let filePath: String
    public let symbolName: String
    public let chunkKind: ChunkKind
    public let startLine: Int
    public let endLine: Int
    public let signature: String
    public let docComment: String
    public let content: String
    public let referencedSymbols: [String]

    public enum ChunkKind: String, Sendable, Codable, Equatable {
        case `actor`
        case `class`
        case `struct`
        case `enum`
        case `protocol`
        case `extension`
        case `func`
        case `property`
        case `typealias`
        case `other`
    }

    public init(
        id: String = UUID().uuidString.lowercased(),
        filePath: String,
        symbolName: String,
        chunkKind: ChunkKind,
        startLine: Int,
        endLine: Int,
        signature: String,
        docComment: String = "",
        content: String,
        referencedSymbols: [String] = []
    ) {
        self.id = id
        self.filePath = filePath
        self.symbolName = symbolName
        self.chunkKind = chunkKind
        self.startLine = startLine
        self.endLine = endLine
        self.signature = signature
        self.docComment = docComment
        self.content = content
        self.referencedSymbols = referencedSymbols
    }

    /// Generates a high-density semantic text representation engineered specifically for vector embedding models.
    /// Combines split identifier words, cleaned doc comments, declaration signatures, and referenced symbols,
    /// eliminating syntax noise (braces, boilerplate) to maximize embedding cosine similarity against natural language queries.
    public var enrichedSemanticText: String {
        var sections: [String] = []

        // 1. Symbol intent & kind with split identifiers
        let words = SwiftSyntaxHelpers.splitIdentifier(symbolName).joined(separator: " ")
        sections.append("Swift \(chunkKind.rawValue) \(symbolName): \(words)")

        // 2. Doc comments (highest semantic intent value)
        if !docComment.isEmpty {
            let cleanDocs = SwiftSyntaxHelpers.cleanDocComment(docComment)
            sections.append("Description: \(cleanDocs)")
        }

        // 3. Normalized Signature
        if !signature.isEmpty {
            sections.append("Signature: \(signature)")
        }

        // 4. Dependencies / referenced symbols
        if !referencedSymbols.isEmpty {
            let refWords = referencedSymbols.flatMap { SwiftSyntaxHelpers.splitIdentifier($0) }.prefix(15)
            sections.append("Keywords: \(refWords.joined(separator: " "))")
        }

        return sections.joined(separator: "\n")
    }
}
