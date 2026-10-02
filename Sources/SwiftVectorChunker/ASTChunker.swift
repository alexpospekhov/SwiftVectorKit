import Foundation
import SwiftVectorCore

/// Production-grade AST chunker for Swift source files.
/// Identifies declaration boundaries (struct, class, actor, protocol, enum, extension, func),
/// tracks nested braces, extracts doc comments, signatures, and referenced symbols.
public struct ASTChunker: Sendable {
    public init() {}

    public func chunk(fileURL: URL) throws -> [CodeChunk] {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        return chunk(source: content, filePath: fileURL.path)
    }

    public func chunk(source: String, filePath: String) -> [CodeChunk] {
        let lines = source.components(separatedBy: "\n")
        var chunks: [CodeChunk] = []

        var currentDocComments: [String] = []
        var i = 0

        while i < lines.count {
            let rawLine = lines[i]
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)

            // Doc comment tracking
            if trimmed.hasPrefix("///") {
                let comment = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                currentDocComments.append(comment)
                i += 1
                continue
            } else if trimmed.hasPrefix("//") {
                i += 1
                continue
            } else if trimmed.isEmpty {
                if !currentDocComments.isEmpty && i + 1 < lines.count && lines[i + 1].trimmingCharacters(in: .whitespaces).isEmpty {
                    currentDocComments.removeAll()
                }
                i += 1
                continue
            }

            // Skip attributes and macros (e.g. @Observable, @Model, @MainActor, @Sendable)
            if trimmed.hasPrefix("@") {
                i += 1
                continue
            }

            // Check for declaration keywords
            if let decl = matchDeclaration(line: trimmed) {
                let startLine = i + 1
                let docComment = currentDocComments.joined(separator: "\n")
                currentDocComments.removeAll()

                // Find declaration body end line via brace counting
                var openBraces = 0
                var foundFirstBrace = false
                var endLine = startLine
                var blockLines: [String] = []

                for j in i..<lines.count {
                    let line = lines[j]
                    blockLines.append(line)

                    for char in line {
                        if char == "{" {
                            openBraces += 1
                            foundFirstBrace = true
                        } else if char == "}" {
                            openBraces -= 1
                        }
                    }

                    if foundFirstBrace && openBraces <= 0 {
                        endLine = j + 1
                        i = j + 1
                        break
                    }

                    if j == lines.count - 1 {
                        endLine = lines.count
                        i = lines.count
                    }
                }

                let blockContent = blockLines.joined(separator: "\n")
                let signature = extractSignature(lines: blockLines)
                let referenced = extractReferencedSymbols(from: blockContent, excluding: decl.symbolName)

                let chunk = CodeChunk(
                    id: "\(filePath):\(decl.symbolName):\(startLine)",
                    filePath: filePath,
                    symbolName: decl.symbolName,
                    chunkKind: decl.kind,
                    startLine: startLine,
                    endLine: endLine,
                    signature: signature,
                    docComment: docComment,
                    content: blockContent,
                    referencedSymbols: referenced
                )
                chunks.append(chunk)
                continue
            }

            currentDocComments.removeAll()
            i += 1
        }

        // Fallback: If no top-level declarations were matched, return entire file as a single chunk
        if chunks.isEmpty && !source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            chunks.append(
                CodeChunk(
                    id: "\(filePath):file:1",
                    filePath: filePath,
                    symbolName: URL(fileURLWithPath: filePath).deletingPathExtension().lastPathComponent,
                    chunkKind: .other,
                    startLine: 1,
                    endLine: max(1, lines.count),
                    signature: URL(fileURLWithPath: filePath).lastPathComponent,
                    docComment: "",
                    content: source,
                    referencedSymbols: []
                )
            )
        }

        return chunks
    }

    private struct MatchedDecl {
        let kind: CodeChunk.ChunkKind
        let symbolName: String
    }

    private func matchDeclaration(line: String) -> MatchedDecl? {
        let tokens = line.components(separatedBy: CharacterSet.whitespaces.union(CharacterSet(charactersIn: ":<{(")))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let modifiers: Set<String> = [
            "public", "private", "fileprivate", "internal", "open", "final",
            "static", "mutating", "nonmutating", "override", "weak", "unowned",
            "indirect", "convenience", "required", "lazy", "dynamic", "package",
            "isolated", "nonisolated"
        ]

        var idx = 0
        while idx < tokens.count && modifiers.contains(tokens[idx]) {
            idx += 1
        }

        guard idx < tokens.count else { return nil }
        let keyword = tokens[idx]

        let kindMap: [String: CodeChunk.ChunkKind] = [
            "actor": .actor,
            "class": .class,
            "struct": .struct,
            "enum": .enum,
            "protocol": .protocol,
            "extension": .extension,
            "func": .func,
            "typealias": .typealias
        ]

        guard let kind = kindMap[keyword] else { return nil }

        if idx + 1 < tokens.count {
            let symbol = tokens[idx + 1]
            return MatchedDecl(kind: kind, symbolName: symbol)
        }

        return nil
    }

    private func extractSignature(lines: [String]) -> String {
        var sigParts: [String] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if let braceIdx = trimmed.firstIndex(of: "{") {
                let beforeBrace = trimmed[..<braceIdx].trimmingCharacters(in: .whitespaces)
                if !beforeBrace.isEmpty {
                    sigParts.append(beforeBrace)
                }
                break
            } else {
                sigParts.append(trimmed)
            }
        }
        return sigParts.joined(separator: " ")
    }

    private func extractReferencedSymbols(from code: String, excluding: String) -> [String] {
        var found: Set<String> = []
        let words = code.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 3 }

        let swiftKeywords: Set<String> = [
            "var", "let", "func", "return", "guard", "else", "if", "for", "in",
            "while", "switch", "case", "default", "break", "continue", "throw",
            "throws", "try", "catch", "async", "await", "self", "Self", "true",
            "false", "nil", "import", "public", "private", "struct", "class",
            "enum", "protocol", "extension", "init", "deinit", "actor"
        ]

        for word in words {
            if word != excluding && !swiftKeywords.contains(word) {
                // Heuristic: PascalCase (Types) or camelCase with at least one uppercase letter
                if word.first?.isUppercase == true || word.contains(where: { $0.isUppercase }) {
                    found.insert(word)
                }
            }
        }

        return Array(found).sorted().prefix(15).map { $0 }
    }
}
