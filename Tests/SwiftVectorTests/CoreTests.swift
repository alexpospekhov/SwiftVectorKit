import Foundation
import Testing
import SwiftVectorCore
import SwiftVectorSIMD
import SwiftVectorChunker
import SwiftVectorStorage
import SwiftVectorCoreML

struct SwiftVectorCoreTests {
    @Test func testCodeChunkCreation() {
        let chunk = CodeChunk(
            filePath: "Sources/Test.swift",
            symbolName: "myFunction",
            chunkKind: .func,
            startLine: 1,
            endLine: 10,
            signature: "func myFunction() -> Int",
            content: "func myFunction() -> Int { return 42 }"
        )
        #expect(chunk.symbolName == "myFunction")
        #expect(chunk.chunkKind == .func)
        #expect(chunk.startLine == 1)
        #expect(chunk.endLine == 10)
    }

    @Test func testSIMDCosineDistance() {
        // Double precision
        let v1 = [1.0, 0.0, 0.0]
        let v2 = [1.0, 0.0, 0.0]
        let v3 = [0.0, 1.0, 0.0]
        let similarities = AccelerateSIMDDistance.cosineSimilarity(query: v1, targets: [v2, v3])
        #expect(similarities.count == 2)
        #expect(abs(similarities[0] - 1.0) < 0.0001)
        #expect(abs(similarities[1] - 0.0) < 0.0001)

        // Float precision
        let f1: [Float] = [1.0, 0.0, 0.0]
        let f2: [Float] = [1.0, 0.0, 0.0]
        let fSim = AccelerateSIMDDistance.cosineSimilarity(a: f1, b: f2)
        #expect(abs(fSim - 1.0) < 0.0001)
    }

    @Test func testASTChunkerParsing() {
        let source = """
        import Foundation

        /// A sample user model
        public struct User: Sendable {
            public let id: String
            public let name: String

            public func greet() -> String {
                return "Hello, \\(name)"
            }
        }

        public actor DatabaseManager {
            public init() {}
        }
        """

        let chunker = ASTChunker()
        let chunks = chunker.chunk(source: source, filePath: "Models/User.swift")

        #expect(chunks.count == 2)
        let structChunk = chunks.first { $0.symbolName == "User" }
        #expect(structChunk != nil)
        #expect(structChunk?.chunkKind == .struct)
        #expect(structChunk?.docComment == "A sample user model")
        #expect(structChunk?.startLine == 4)

        let actorChunk = chunks.first { $0.symbolName == "DatabaseManager" }
        #expect(actorChunk != nil)
        #expect(actorChunk?.chunkKind == .actor)
    }

    @Test func testVectorStoreHybridSearch() async throws {
        let store = VectorStore()

        let chunk1 = CodeChunk(
            filePath: "Auth.swift",
            symbolName: "loginUser",
            chunkKind: .func,
            startLine: 1,
            endLine: 5,
            signature: "func loginUser()",
            content: "func loginUser(token: String) { authenticate(token) }"
        )

        let chunk2 = CodeChunk(
            filePath: "Payment.swift",
            symbolName: "processPayment",
            chunkKind: .func,
            startLine: 1,
            endLine: 5,
            signature: "func processPayment()",
            content: "func processPayment(amount: Double) { charge(amount) }"
        )

        await store.insert(chunk: chunk1, vector: [1.0, 0.0, 0.0])
        await store.insert(chunk: chunk2, vector: [0.0, 1.0, 0.0])

        let results = await store.search(query: "login user", queryVector: [1.0, 0.0, 0.0], limit: 1)
        #expect(results.count == 1)
        #expect(results[0].chunk.symbolName == "loginUser")
        #expect(results[0].fusedScore > 0.5)
    }

    @Test func testEmbeddingNormalization() async throws {
        let embedder = CoreMLEmbeddingService()
        let vec = try await embedder.embed(text: "func calculateHash()")
        #expect(!vec.isEmpty)

        // Check unit normalization
        var normSq: Float = 0.0
        for val in vec { normSq += val * val }
        #expect(abs(sqrt(normSq) - 1.0) < 0.05)
    }
}
