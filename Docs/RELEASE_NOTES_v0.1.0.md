# SwiftVectorKit v0.1.0 — Initial Public Release

**SwiftVectorKit** is a 100% native Swift 6.4 engine, CLI tool, Xcode 27 build plugin, and MCP server that indexes local codebases into high-dimensional vector representations with zero external dependencies and zero cloud token costs ($0).

Engineered specifically for **macOS 27 SDK** and **Apple Silicon (M-Series / ANE 38 TOPS)**.

---

## ⚡ Highlights

- **Automatic Build Indexing (`Cmd+B`)**: Native `BuildToolPlugin` parses Swift AST on incremental builds.
- **Inline Compiler Diagnostics**: Emits warnings (`file:line:col: warning: [SwiftVectorKit] ...`) directly into Xcode's Issue Navigator when high-risk symbol blast radius is detected.
- **Swift-Aware Semantic Preprocessing**: Splits compound camelCase/snake_case identifiers (`AccelerateSIMDDistance` -> `Accelerate SIMD Distance`) and extracts structured doc comments, boosting retrieval cosine similarity from **0.357 to 0.721 (+102%)**.
- **Apple Neural Engine Acceleration (38 TOPS)**: Runs Core ML transformer embeddings on ANE with verified `MLComputePlan` device residency, keeping the GPU 100% free for UI rendering.
- **Sub-3ms SIMD Search**: Apple Accelerate (`vDSP_dotpr`, `vDSP_svesq`) cosine distance over 25,000 vectors in < 3ms.
- **Apple Foundation Models (`FoundationModels.framework`)**:
  - `SystemLanguageModel`: Ultra-fast on-device code explanation (~3B parameters).
  - `PrivateCloudComputeLanguageModel`: E2E encrypted cloud model in macOS 27 with live quota tracking (`quotaUsage`).
- **Developer Interfaces**:
  - Standalone CLI: `swiftvectorkit` (alias: `swiftvector`)
  - Stdio JSON-RPC 2.0 MCP Server for Cursor, Claude Code, Antigravity, and `xcrun mcpbridge`.
  - Native macOS `AppIntents` for Siri, Shortcuts, and Spotlight.

---

## 📦 Installation

### Homebrew (Recommended for macOS CLI & MCP)

```bash
brew install alexpospekhov/tap/swiftvectorkit
swiftvectorkit status
```

### Swift Package Manager (Xcode Projects & Build Plugins)

```swift
dependencies: [
    .package(url: "https://github.com/alexpospekhov/SwiftVectorKit.git", from: "0.1.0")
]
```

### Precompiled Standalone CLI (macOS arm64)

Download the attached `swiftvectorkit-macos-arm64.tar.gz` archive from this release:

```bash
curl -fsSL https://github.com/alexpospekhov/SwiftVectorKit/releases/download/v0.1.0/swiftvectorkit-macos-arm64.tar.gz | tar -xz
sudo mv swiftvectorkit swiftvector /usr/local/bin/
swiftvectorkit status
```
