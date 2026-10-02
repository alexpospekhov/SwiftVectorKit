# Contributing to SwiftVectorKit

Thank you for your interest in contributing to SwiftVectorKit!

SwiftVectorKit is an open-source, 100% native Swift 6.4 engine for on-device code intelligence, vector embeddings on Apple Neural Engine (ANE 38 TOPS), and deep Xcode integration.

## Development Principles

1. **Swift-Only**: All code, tools, and tests must be native Swift 6.4 with Strict Concurrency. No external runtime scripts (Python, Ruby, shell wrappers).
2. **Apple Silicon First**: Take direct advantage of Apple Silicon hardware:
   - ANE (Apple Neural Engine) via Core ML (`MLComputePlan`)
   - SIMD vector acceleration via Apple `Accelerate` (`vDSP`)
   - Local intelligence via Apple Foundation Models (`FoundationModels.framework`)
3. **Zero Zombie Tasks & Structured Concurrency**: Use `swiftlang/swift-subprocess` and native Swift `actor` / `Sendable` types.
4. **Privacy & Local-First**: $0 cloud token costs. Code stays 100% on the developer's machine unless explicitly directed otherwise.

## Getting Started

```bash
git clone https://github.com/alexpospekhov/SwiftVectorKit.git
cd SwiftVectorKit
swift test
swift run swiftvectorkit status
```

## Pull Request Guidelines

1. Ensure all unit tests pass with `swift test`.
2. Format code according to standard Swift conventions (`swift-format` where applicable).
3. Update or add unit tests for any new features or bug fixes.
4. Keep PR descriptions clear, outlining the problem solved and test results.
