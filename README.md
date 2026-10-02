<div align="center">
  <img src="Assets/icon.png" width="128" alt="SwiftVectorKit Icon" />
  <h1>SwiftVectorKit</h1>
  <p><strong>v0.1.0 — On-Device Semantic Code Search, AST Vector Indexing & Agentic Intelligence for Swift on Apple Silicon</strong></p>

  [![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)]()
  [![Language](https://img.shields.io/badge/Swift-6.4%20Strict%20Concurrency-orange.svg)](https://swift.org)
  [![Platform](https://img.shields.io/badge/macOS-15.0%2B%20%7C%20Apple%20Silicon-black.svg)]()
  [![Xcode](https://img.shields.io/badge/Xcode-16.0%2B-blue.svg)]()
  [![Hardware](https://img.shields.io/badge/Neural%20Engine-38%20TOPS%20ANE-purple.svg)]()
  [![Apple FM](https://img.shields.io/badge/Apple%20FM-SystemLanguageModel%20%2B%20PCC-gradient.svg)]()
  [![SIMD](https://img.shields.io/badge/Vector%20Search-Accelerate%20vDSP%20(%3C3ms)-green.svg)]()
  [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
</div>

---

## Terminal Session

![SwiftVectorKit Terminal Demo](Assets/demo.gif)

---

## The Problem: Why Keyword Search and Cloud RAG Fail Autonomous Agents

Autonomous software engineering agents (Claude Code, Cursor, Codex, Antigravity, and Xcode agents) face critical bottlenecks when navigating medium-to-large Swift repositories:

### 1. Context Window Exhaustion and Grep Blindness
Standard string-matching tools (`grep`, `ripgrep`, `Cmd+Shift+F`) match literal characters, not architectural semantics. When an agent searches for *"thread-safe vector storage"*, keyword matching fails to locate `@ModelActor final class VectorStore` unless the agent already knows the exact type name. Grep-based agents compensate by dumping thousands of irrelevant lines into their context window, inducing attention degradation, token exhaustion, and hallucinated modifications.

### 2. Cascading Refactoring Failures
Autonomous coding agents lack visibility into symbol blast radiuses. When an agent refactors a protocol, actor isolation boundary, or public interface, it frequently breaks dependent modules across the workspace without realizing it until compiler execution fails, trapping the agent in recursive debug loops.

### 3. Latency, Recurring API Costs, and Intellectual Property Leakage
Cloud-based code vectorization solutions (Pinecone, Chroma, OpenAI embeddings) introduce severe operational friction:
- Every agent reasoning step incurs 500ms to 2000ms of external network round-trip latency.
- Proprietary enterprise source code is continuously transmitted to third-party model providers.
- Heavy Python-based RAG sidecars (LangChain, Docker, virtual environments) add massive foreign dependencies incompatible with native Swift developer workflows.

---

## The Solution: On-Device Semantic Infrastructure for Agentic Coding

**SwiftVectorKit** provides an offline, hardware-accelerated code intelligence substrate built specifically for autonomous agents and Apple Silicon:

### Sub-3ms Semantic Grounding via Model Context Protocol (MCP)
SwiftVectorKit runs a native stdio Model Context Protocol (MCP) server (`swiftvectorkit mcp`). Autonomous agents can issue natural language architectural intent queries (*"where is actor reentrancy handled in memory stores?"*) and receive precise AST declaration chunks with file paths, symbol boundaries, and line ranges in under 3 milliseconds. An agent can execute hundreds of semantic retrieval passes per task with zero cloud latency and zero token costs ($0).

### Swift-Aware AST Semantic Enrichment
Raw source code vectors produce noisy embeddings because compiler punctuation and compound identifiers are not natural language tokens. SwiftVectorKit parses Swift AST declaration boundaries and enriches tokens before vectorization:
- Compound identifiers are split into natural semantic phrases (`AccelerateSIMDDistance` -> `Accelerate SIMD Distance`).
- Structured docstrings (`/// ...`) and parameter contracts are extracted and weighted.
- Boosts retrieval cosine similarity from **0.357 to 0.721 (+102%)** compared to raw code embedding.

### Compiler-Grade Refactoring Diagnostics
Via `SwiftVectorAutoIndexPlugin` (`capability: .buildTool()`), SwiftVectorKit incrementally parses and re-indexes AST declarations during every Xcode build (`Cmd+B`). When high-risk symbol blast radius is detected, the engine emits native compiler diagnostics directly into Xcode's Issue Navigator:
```text
Sources/Core/Storage.swift:42:1: warning: [SwiftVectorKit] High blast radius: modifying 'VectorStore' impacts 14 dependent symbols across 3 targets.
```

### 100% Local Hardware Exploitation on Apple Silicon
- **Apple Neural Engine (38 TOPS)**: Executes Core ML transformer embeddings directly on ANE via `MLComputePlan`, keeping Metal GPU cores 100% free for UI and simulator rendering.
- **Apple Accelerate SIMD**: Hardware-accelerated batch vector distance calculations (`vDSP_dotpr`, `vDSP_svesq`) evaluating 25,000 code vectors in sub-3ms.
- **Dual-Tier Apple Foundation Models**: Integrated support for local `SystemLanguageModel` (~3B parameters) for instant symbol explanation, with seamless fallback to `PrivateCloudComputeLanguageModel`.

---

## Architecture Specifications

| Module | Architectural Role | Implementation Substrate |
|---|---|---|
| `SwiftVectorCore` | Domain models, declaration boundaries, semantic AST enrichment | Swift 6.4 Strict Concurrency, `Sendable` structs |
| `SwiftVectorScanner` | High-throughput workspace file discovery and filtering | Pure Swift directory enumeration, extension matching |
| `SwiftVectorChunker` | Swift declaration boundary extraction and brace balance tracking | Deterministic lexical state machine |
| `SwiftVectorTokenizer` | Compound identifier splitting and docstring cleaning | Pure Swift BPE / WordPiece tokenizer |
| `SwiftVectorSIMD` | Batch vector cosine similarity ranking | Apple `Accelerate.framework` (`vDSP_dotpr`, `vDSP_svesq`) |
| `SwiftVectorCoreML` | Neural embedding inference on Apple Neural Engine | Core ML (`MLModel`, `MLComputePlan`, `NLEmbedding`) |
| `SwiftVectorStorage` | Actor-isolated in-memory store with Reciprocal Rank Fusion | Swift Actor, atomic JSON persistence |
| `SwiftVectorFM` | Apple Foundation Models bridge for automated code explanation | `FoundationModels.framework` (`SystemLanguageModel`, `PCC`) |
| `SwiftVectorSCIP` | Symbol graph resolution and refactoring blast radius analysis | SCIP symbol graph indexer, `swift-subprocess` |
| `SwiftVectorMCP` | Stdio JSON-RPC 2.0 server for AI IDEs | Claude Code, Cursor, Antigravity, `xcrun mcpbridge` |
| `SwiftVectorAutoIndexPlugin` | Incremental AST indexing during Xcode builds (`Cmd+B`) | Swift Package Manager `BuildToolPlugin` |
| `SwiftVectorCLI` | Standalone executable command-line interface | Universal Mach-O arm64 binary (`swiftvectorkit`) |

---

## Installation

### 1. Homebrew (macOS CLI & MCP Server)

Install the compiled binary and MCP server on Apple Silicon:

```bash
brew install alexpospekhov/tap/swiftvectorkit
```

Verify installation:
```bash
swiftvectorkit status
```

### 2. Swift Package Manager (Xcode Projects & Build Plugins)

To embed SwiftVectorKit as a library or enable automatic build-time AST indexing in your Xcode target:

Add to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/alexpospekhov/SwiftVectorKit.git", from: "0.1.0")
]
```

Link the library:

```swift
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "SwiftVectorKit", package: "SwiftVectorKit")
    ]
)
```

Enable automatic build-time indexing (`Cmd+B`):

```swift
.target(
    name: "MyTarget",
    plugins: [
        .plugin(name: "SwiftVectorAutoIndexPlugin", package: "SwiftVectorKit")
    ]
)
```

### 3. Standalone Pre-compiled Binary

Download the compiled arm64 Mach-O binary directly from [GitHub Releases](https://github.com/alexpospekhov/SwiftVectorKit/releases/latest):

```bash
curl -fsSL https://github.com/alexpospekhov/SwiftVectorKit/releases/download/v0.1.0/swiftvectorkit-macos-arm64.tar.gz | tar -xz
sudo mv swiftvectorkit swiftvector /usr/local/bin/
```

---

## CLI Usage

Both `swiftvectorkit` and `swiftvector` commands are supported:

```bash
# Check Apple Silicon hardware acceleration and Foundation Models status
swiftvectorkit status

# Index a workspace or directory
swiftvectorkit index Sources/

# Execute hybrid semantic search
swiftvectorkit search "Accelerate SIMD cosine distance" --limit 3

# Explain symbol architecture via Apple Foundation Models
swiftvectorkit explain AccelerateSIMDDistance

# Launch stdio MCP server for Claude Code, Cursor, and Antigravity
swiftvectorkit mcp
```

---

## Agentic IDE Configuration (Cursor, Claude Code, Antigravity)

To configure SwiftVectorKit as an MCP server for autonomous coding agents, add the following configuration:

### Cursor (`~/.cursor/mcp.json`) / Claude Code (`~/.claude/mcp.json`):

```json
{
  "mcpServers": {
    "swiftvectorkit": {
      "command": "/opt/homebrew/bin/swiftvectorkit",
      "args": ["mcp"]
    }
  }
}
```

---

## Architecture & Technical References

- [Architecture Specification (`Docs/ARCHITECTURE.md`)](Docs/ARCHITECTURE.md)
- [Release Roadmap (`Docs/ROADMAP.md`)](Docs/ROADMAP.md)
- [Xcode 27 & Apple FM SDK Audit (`Docs/SDK_AUDIT.md`)](Docs/SDK_AUDIT.md)

---

## License

SwiftVectorKit is released under the [Apache License 2.0](LICENSE).
