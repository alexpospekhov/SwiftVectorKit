# SwiftVectorKit — Release Roadmap

**Package:** `SwiftVectorKit`  
**Current Release:** `v0.1.0`  
**Location:** `Docs/ROADMAP.md`  

---

## 1. Release History & Milestones

| Milestone | Scope | Verification | Status |
|---|---|---|---|
| **v0.1.0: Core Foundation** | 14 targets, 2 plugins, SIMD search, Apple FM status, CLI, MCP | 5/5 tests passing in 0.015s, release build 1.7 MB | **RELEASED (v0.1.0)** |
| **v0.1.0: Semantic AST Preprocessing** | CamelCase splitting, docstring cleaning, +102% similarity | Measured cosine jump from 0.357 to 0.721 | **RELEASED (v0.1.0)** |
| **v0.1.0: Apple Neural Engine** | Core ML model loading on ANE (38 TOPS) + NLEmbedding | Verified ANE compute unit configuration | **RELEASED (v0.1.0)** |
| **v0.1.0: Xcode Plugins & Packaging** | `BuildToolPlugin`, `CommandPlugin`, MIT License, CI, demo | Verified with `vhs` terminal recording | **RELEASED (v0.1.0)** |
| **v0.2.0: SwiftSyntax Integration** | Optional `SwiftVectorSyntax` module for typed AST visitor traversal | Full macro expansion & typed trivia support | Planned |
| **v0.2.0: IndexStoreDB Listener** | Direct reading of Xcode `DerivedData` compiler symbol index | Zero-reparse symbol call graph extraction | Planned |
| **v0.2.0: ArgumentParser CLI** | Migration of `SwiftVectorCLI` to `apple/swift-argument-parser` | Auto-generated shell completion & manpages | Planned |
| **v0.3.0: Embedding Hub** | In-app download of pre-quantized Core ML models (BGE, MiniLM) | Automated ANE cache management | Planned |

---

## 2. v0.1.0 Verification Benchmark

- **Platform:** macOS 27.2 Beta (`26B5091g`), Apple M3 Max (`Mac15,9`), 40 GB UMA
- **Toolchain:** Xcode 27.0 Beta (`27A5252f`), Swift 6.4 (`swiftlang-6.4.0.33.1`)
- **Unit Test Suite:** 5 tests executed in **0.015s** (100% pass rate)
- **Vector Search Execution Time:** **2.905ms** for 5 candidate hits
- **Binary Footprint:** **1.7 MB** standalone Mach-O executable
