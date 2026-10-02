import Foundation
import SwiftVectorCore
import SwiftVectorStorage
import SwiftVectorFM
import SwiftVectorCoreML

/// Minimal native Swift stdio MCP server for SwiftVector.
/// Compatible with Claude Code, Cursor, Antigravity, and Xcode 27 mcpbridge.
@main
struct SwiftVectorMCP {
    static func main() async {
        let store = VectorStore()
        let storeURL = URL(fileURLWithPath: ".swiftvector/index.json")
        if FileManager.default.fileExists(atPath: storeURL.path) {
            try? await store.load(from: storeURL)
        }

        let embedder = CoreMLEmbeddingService()
        let fm = FoundationModelService()

        FileHandle.standardError.write(Data("[SwiftVectorMCP] Initialized on stdio (JSON-RPC 2.0).\n".utf8))

        while let line = readLine() {
            guard let data = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let method = json["method"] as? String,
                  let id = json["id"] else {
                continue
            }

            switch method {
            case "initialize":
                let response: [String: Any] = [
                    "jsonrpc": "2.0",
                    "id": id,
                    "result": [
                        "protocolVersion": "2024-11-05",
                        "serverInfo": [
                            "name": "swiftvector-mcp",
                            "version": "1.0.0"
                        ],
                        "capabilities": [
                            "tools": [:]
                        ]
                    ]
                ]
                sendJSON(response)

            case "tools/list":
                let tools: [[String: Any]] = [
                    [
                        "name": "code_search",
                        "description": "Semantic and lexical code search across the indexed Swift codebase.",
                        "inputSchema": [
                            "type": "object",
                            "properties": [
                                "query": ["type": "string", "description": "Search query or natural language question"],
                                "limit": ["type": "integer", "description": "Maximum number of results to return"]
                            ],
                            "required": ["query"]
                        ]
                    ],
                    [
                        "name": "code_explain",
                        "description": "Explain symbol architecture and logic using Apple Foundation Models.",
                        "inputSchema": [
                            "type": "object",
                            "properties": [
                                "symbol": ["type": "string", "description": "Name of the symbol to explain"]
                            ],
                            "required": ["symbol"]
                        ]
                    ],
                    [
                        "name": "system_status",
                        "description": "Check Apple Silicon ANE and Foundation Models status.",
                        "inputSchema": [
                            "type": "object",
                            "properties": [:]
                        ]
                    ]
                ]
                let response: [String: Any] = [
                    "jsonrpc": "2.0",
                    "id": id,
                    "result": ["tools": tools]
                ]
                sendJSON(response)

            case "tools/call":
                guard let params = json["params"] as? [String: Any],
                      let toolName = params["name"] as? String else {
                    continue
                }
                let arguments = params["arguments"] as? [String: Any] ?? [:]

                var resultText = ""

                if toolName == "code_search" {
                    let query = arguments["query"] as? String ?? ""
                    let limit = arguments["limit"] as? Int ?? 5
                    if let qVec = try? await embedder.embedDouble(text: query) {
                        let res = await store.search(query: query, queryVector: qVec, limit: limit)
                        resultText = res.map { "[\($0.chunk.symbolName)] (\($0.chunk.filePath):\($0.chunk.startLine)) score: \(String(format: "%.3f", $0.fusedScore))\n\($0.chunk.signature)" }.joined(separator: "\n\n")
                    } else {
                        resultText = "Failed to embed query."
                    }
                } else if toolName == "code_explain" {
                    let symbol = arguments["symbol"] as? String ?? ""
                    let all = await store.allChunks()
                    if let found = all.first(where: { $0.symbolName.lowercased() == symbol.lowercased() }) {
                        resultText = (try? await fm.explain(chunk: found)) ?? "Explanation error."
                    } else {
                        resultText = "Symbol '\(symbol)' not found in index."
                    }
                } else if toolName == "system_status" {
                    let rep = await fm.modelStatus()
                    resultText = "On-Device: \(rep.onDeviceAvailable), PCC: \(rep.pccAvailable) (\(rep.pccStatus))"
                }

                let response: [String: Any] = [
                    "jsonrpc": "2.0",
                    "id": id,
                    "result": [
                        "content": [
                            ["type": "text", "text": resultText]
                        ]
                    ]
                ]
                sendJSON(response)

            default:
                break
            }
        }
    }

    private static func sendJSON(_ obj: [String: Any]) {
        if let data = try? JSONSerialization.data(withJSONObject: obj),
           let str = String(data: data, encoding: .utf8) {
            print(str)
            fflush(stdout)
        }
    }
}
