import Foundation
import SwiftVectorCore
import SwiftVectorSIMD

/// In-memory and persistent vector index with hybrid vector + lexical search.
public actor VectorStore {
    private var chunks: [String: CodeChunk] = [:]
    private var vectors: [String: [Double]] = [:]

    public init() {}

    public var count: Int {
        chunks.count
    }

    public func insert(chunk: CodeChunk, vector: [Double]) {
        chunks[chunk.id] = chunk
        vectors[chunk.id] = vector
    }

    public func getChunk(id: String) -> CodeChunk? {
        chunks[id]
    }

    public func allChunks() -> [CodeChunk] {
        Array(chunks.values)
    }

    /// Hybrid search: Combines Accelerate SIMD vector distance with lexical token matching.
    public func search(
        query: String,
        queryVector: [Double],
        limit: Int = 10,
        filterPrefix: String? = nil
    ) -> [SearchResult] {
        var eligibleKeys = Array(vectors.keys)
        if let prefix = filterPrefix, !prefix.isEmpty {
            eligibleKeys = eligibleKeys.filter { key in
                chunks[key]?.filePath.hasPrefix(prefix) == true
            }
        }
        guard !eligibleKeys.isEmpty else { return [] }

        // 1. Vector SIMD similarity
        let matrix = eligibleKeys.compactMap { vectors[$0] }
        let vectorScores = AccelerateSIMDDistance.cosineSimilarity(query: queryVector, targets: matrix)

        // 2. Lexical token overlap
        let queryTokens = Set(query.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty })

        var scoredItems: [(chunk: CodeChunk, vScore: Double, lScore: Double, fused: Double)] = []

        for (i, key) in eligibleKeys.enumerated() {
            guard let chunk = chunks[key] else { continue }
            let vScore = vectorScores[i]

            // Calculate lexical score based on symbol name, split words, doc comment, and content
            var lScore: Double = 0.0
            if !queryTokens.isEmpty {
                let symbolLower = chunk.symbolName.lowercased()
                let splitWords = Set(SwiftSyntaxHelpers.splitIdentifier(chunk.symbolName).map { $0.lowercased() })
                let docLower = chunk.docComment.lowercased()
                let contentLower = chunk.content.lowercased()
                var matchCount = 0

                for token in queryTokens {
                    if symbolLower == token {
                        matchCount += 6 // exact full identifier match
                    } else if splitWords.contains(token) {
                        matchCount += 4 // split word match (e.g. "simd" in "AccelerateSIMDDistance")
                    } else if docLower.contains(token) {
                        matchCount += 3 // matched in doc comment
                    } else if symbolLower.contains(token) {
                        matchCount += 2
                    } else if contentLower.contains(token) {
                        matchCount += 1
                    }
                }
                lScore = min(1.0, Double(matchCount) / Double(queryTokens.count * 4))
            }

            // Reciprocal Rank Fusion / weighted combination: 0.6 vector + 0.4 lexical
            let fused = (vScore * 0.6) + (lScore * 0.4)
            scoredItems.append((chunk, vScore, lScore, fused))
        }

        // Sort descending by fused score
        scoredItems.sort { $0.fused > $1.fused }

        return scoredItems.prefix(limit).map { item in
            SearchResult(
                chunk: item.chunk,
                vectorScore: item.vScore,
                lexicalScore: item.lScore,
                fusedScore: item.fused
            )
        }
    }

    // MARK: - Persistence

    private struct IndexArchive: Codable {
        let chunks: [CodeChunk]
        let vectors: [String: [Double]]
    }

    public func save(to fileURL: URL) throws {
        let archive = IndexArchive(chunks: Array(chunks.values), vectors: vectors)
        let data = try JSONEncoder().encode(archive)
        let dir = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        try data.write(to: fileURL, options: .atomic)
    }

    public func load(from fileURL: URL) throws {
        let data = try Data(contentsOf: fileURL)
        let archive = try JSONDecoder().decode(IndexArchive.self, from: data)
        self.chunks.removeAll()
        self.vectors.removeAll()
        for chunk in archive.chunks {
            self.chunks[chunk.id] = chunk
        }
        self.vectors = archive.vectors
    }
}
