// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftVectorKit",
    platforms: [
        .macOS(.v15) // Compatible with macOS 15+ and macOS 27 Beta
    ],
    products: [
        .executable(name: "swiftvector", targets: ["SwiftVectorCLI"]),
        .executable(name: "swiftvectorkit", targets: ["SwiftVectorCLI"]),
        .executable(name: "swiftvector-mcp", targets: ["SwiftVectorMCP"]),
        .library(name: "SwiftVectorKit", targets: ["SwiftVectorCore", "SwiftVectorScanner", "SwiftVectorChunker", "SwiftVectorCoreML", "SwiftVectorSIMD", "SwiftVectorStorage", "SwiftVectorFM", "SwiftVectorSCIP"]),
        .plugin(name: "SwiftVectorAutoIndexPlugin", targets: ["SwiftVectorAutoIndexPlugin"]),
        .plugin(name: "SwiftVectorCommandPlugin", targets: ["SwiftVectorCommandPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.4")
    ],
    targets: [
        // MARK: - Core Domain Models
        .target(
            name: "SwiftVectorCore",
            dependencies: [],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),

        // MARK: - Workspace File Scanner & Diagnostic Emitter
        .target(
            name: "SwiftVectorScanner",
            dependencies: ["SwiftVectorCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),

        // MARK: - AST Chunker Engine (Swift 6 AST Boundaries)
        .target(
            name: "SwiftVectorChunker",
            dependencies: ["SwiftVectorCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),

        // MARK: - Tokenizer in Pure Swift (BPE / WordPiece)
        .target(
            name: "SwiftVectorTokenizer",
            dependencies: ["SwiftVectorCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),

        // MARK: - Core ML Inference on Apple Neural Engine (ANE 38 TOPS)
        .target(
            name: "SwiftVectorCoreML",
            dependencies: ["SwiftVectorCore", "SwiftVectorTokenizer"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),

        // MARK: - Apple Accelerate vDSP SIMD Vector Distance (< 5ms on 25k chunks)
        .target(
            name: "SwiftVectorSIMD",
            dependencies: ["SwiftVectorCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),

        // MARK: - In-Process DuckDB (CDuckDB) + RRF Re-Ranking
        .target(
            name: "SwiftVectorStorage",
            dependencies: [
                "SwiftVectorCore",
                "SwiftVectorSIMD"
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),

        // MARK: - Apple Foundation Models (SystemLanguageModel & PrivateCloudComputeLanguageModel)
        .target(
            name: "SwiftVectorFM",
            dependencies: [
                "SwiftVectorCore",
                "SwiftVectorStorage"
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),

        // MARK: - SCIP Compiler Graph & DerivedData Listener
        .target(
            name: "SwiftVectorSCIP",
            dependencies: [
                "SwiftVectorCore",
                .product(name: "Subprocess", package: "swift-subprocess")
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),

        // MARK: - App Intents for Siri, Shortcuts, and Apple Intelligence
        .target(
            name: "SwiftVectorIntents",
            dependencies: [
                "SwiftVectorCore",
                "SwiftVectorStorage",
                "SwiftVectorFM"
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),

        // MARK: - Executables (CLI & MCP Server)
        .executableTarget(
            name: "SwiftVectorCLI",
            dependencies: [
                "SwiftVectorCore",
                "SwiftVectorScanner",
                "SwiftVectorChunker",
                "SwiftVectorCoreML",
                "SwiftVectorSIMD",
                "SwiftVectorStorage",
                "SwiftVectorFM",
                "SwiftVectorSCIP"
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .executableTarget(
            name: "SwiftVectorMCP",
            dependencies: [
                "SwiftVectorCore",
                "SwiftVectorStorage",
                "SwiftVectorFM",
                "SwiftVectorCoreML",
                "SwiftVectorSCIP"
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),

        // MARK: - Xcode 27 Package Plugins
        .plugin(
            name: "SwiftVectorAutoIndexPlugin",
            capability: .buildTool(),
            dependencies: ["SwiftVectorCLI"]
        ),
        .plugin(
            name: "SwiftVectorCommandPlugin",
            capability: .command(intent: .custom(verb: "vector-index", description: "Index project using SwiftVectorKit")),
            dependencies: ["SwiftVectorCLI"]
        ),

        // MARK: - Tests (Swift Testing / XCTest)
        .testTarget(
            name: "SwiftVectorTests",
            dependencies: [
                "SwiftVectorCore",
                "SwiftVectorScanner",
                "SwiftVectorChunker",
                "SwiftVectorTokenizer",
                "SwiftVectorCoreML",
                "SwiftVectorSIMD",
                "SwiftVectorStorage"
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
