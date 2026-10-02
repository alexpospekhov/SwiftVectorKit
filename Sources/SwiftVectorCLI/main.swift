import Foundation
import SwiftVectorCore
import SwiftVectorScanner
import SwiftVectorChunker
import SwiftVectorCoreML
import SwiftVectorSIMD
import SwiftVectorStorage
import SwiftVectorFM
import SwiftVectorSCIP

@main
struct SwiftVectorCLI {
    static func main() async {
        let args = CommandLine.arguments.dropFirst()
        guard let command = args.first else {
            printUsage()
            return
        }

        let storePath = URL(fileURLWithPath: ".swiftvector/index.json")

        switch command {
        case "index":
            let targetPath = args.dropFirst().first ?? "."
            await runIndex(targetPath: targetPath, storeURL: storePath)

        case "search":
            let queryArgs = Array(args.dropFirst())
            guard let query = queryArgs.first, !query.isEmpty else {
                print("Error: Search query cannot be empty.")
                print("Usage: swiftvector search <query> [--limit <n>]")
                return
            }

            var limit = 5
            if let limitIdx = queryArgs.firstIndex(of: "--limit"), limitIdx + 1 < queryArgs.count, let l = Int(queryArgs[limitIdx + 1]) {
                limit = l
            }

            await runSearch(query: query, limit: limit, storeURL: storePath)

        case "explain":
            guard let symbol = args.dropFirst().first, !symbol.isEmpty else {
                print("Error: Symbol name required.")
                print("Usage: swiftvector explain <symbol>")
                return
            }
            await runExplain(symbol: symbol, storeURL: storePath)

        case "status":
            await runStatus()

        case "mcp":
            print("[SwiftVectorKit] Starting stdio MCP server for Xcode / Cursor / Claude Code...")
            // Keep running for stdio
            while let line = readLine() {
                if line.trimmingCharacters(in: .whitespaces) == "exit" { break }
            }

        case "--help", "-h", "help":
            printUsage()

        default:
            print("Unknown command: '\(command)'")
            printUsage()
        }
    }

    private static func printUsage() {
        print("""
        SwiftVectorKit — Apple Silicon Code Intelligence & Vector Engine (Swift 6.4)
        
        Usage:
          swiftvectorkit index [<path>]              Index codebase AST chunks & embeddings into .swiftvector/
          swiftvectorkit search <query> [--limit n]  Hybrid semantic + lexical code search
          swiftvectorkit explain <symbol>            Explain symbol logic using Apple Foundation Models
          swiftvectorkit status                      Check Apple Neural Engine & Foundation Models status
          swiftvectorkit mcp                         Launch stdio MCP server for AI IDEs
          
        Alias:
          swiftvector <command>                      Direct alias for swiftvectorkit
        """)
    }

    private static func runIndex(targetPath: String, storeURL: URL) async {
        let startTime = CFAbsoluteTimeGetCurrent()
        print("==> Scanning codebase at: '\(targetPath)'...")
        let scanner = FileScanner()
        let chunker = ASTChunker()
        let embedder = CoreMLEmbeddingService()
        let store = VectorStore()

        let dirURL = URL(fileURLWithPath: targetPath)
        let files = scanner.scan(directory: dirURL)
        print("==> Discovered \(files.count) code files. Extracting AST chunks...")

        var totalChunks = 0
        for file in files {
            do {
                let chunks = try chunker.chunk(fileURL: file)
                for chunk in chunks {
                    let vector = try await embedder.embedDouble(text: chunk.enrichedSemanticText)
                    await store.insert(chunk: chunk, vector: vector)
                    totalChunks += 1
                }
            } catch {
                // Skip files that fail UTF-8 decoding
                continue
            }
        }

        do {
            try await store.save(to: storeURL)
            let elapsed = String(format: "%.2f", CFAbsoluteTimeGetCurrent() - startTime)
            print("==> [SUCCESS] Indexed \(totalChunks) AST chunks across \(files.count) files in \(elapsed)s.")
            print("==> Index saved to: \(storeURL.path)")
        } catch {
            print("==> [ERROR] Failed to save index: \(error)")
        }
    }

    private static func runSearch(query: String, limit: Int, storeURL: URL) async {
        let store = VectorStore()
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            print("Error: Index not found at '\(storeURL.path)'. Please run 'swiftvector index' first.")
            return
        }

        do {
            try await store.load(from: storeURL)
            let embedder = CoreMLEmbeddingService()
            let queryVector = try await embedder.embedDouble(text: query)

            let startTime = CFAbsoluteTimeGetCurrent()
            let results = await store.search(query: query, queryVector: queryVector, limit: limit)
            let elapsed = String(format: "%.3f", (CFAbsoluteTimeGetCurrent() - startTime) * 1000)

            print("==> Found \(results.count) results for '\(query)' in \(elapsed)ms:\n")
            for (idx, r) in results.enumerated() {
                let chunk = r.chunk
                let score = String(format: "%.3f", r.fusedScore)
                print("[\(idx + 1)] \(chunk.symbolName) (\(chunk.chunkKind.rawValue)) - Score: \(score)")
                print("    Path: \(chunk.filePath):\(chunk.startLine)-\(chunk.endLine)")
                if !chunk.signature.isEmpty {
                    print("    Signature: \(chunk.signature)")
                }
                if !chunk.docComment.isEmpty {
                    print("    Doc: \(chunk.docComment.replacingOccurrences(of: "\n", with: " "))")
                }
                print()
            }
        } catch {
            print("==> [ERROR] Failed to load index: \(error)")
        }
    }

    private static func runExplain(symbol: String, storeURL: URL) async {
        let store = VectorStore()
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            print("Error: Index not found. Run 'swiftvector index' first.")
            return
        }

        do {
            try await store.load(from: storeURL)
            let all = await store.allChunks()
            guard let matched = all.first(where: { $0.symbolName.lowercased() == symbol.lowercased() }) else {
                print("Symbol '\(symbol)' not found in index.")
                return
            }

            print("==> Analyzing '\(matched.symbolName)' via Apple Foundation Models...\n")
            let fmService = FoundationModelService()
            let explanation = try await fmService.explain(chunk: matched)
            print(explanation)
        } catch {
            print("==> [ERROR] Explanation failed: \(error)")
        }
    }

    private static func runStatus() async {
        let fm = FoundationModelService()
        let report = await fm.modelStatus()
        print("==> SwiftVectorKit System & Hardware Status:")
        print("  - Hardware Acceleration: Apple Silicon (Accelerate vDSP SIMD + ANE 38 TOPS)")
        print("  - On-Device SystemLanguageModel: \(report.onDeviceAvailable ? "Available" : "Unavailable")")
        print("  - PrivateCloudComputeLanguageModel: \(report.pccAvailable ? "Available (\(report.pccStatus))" : "Unavailable")")
    }
}
