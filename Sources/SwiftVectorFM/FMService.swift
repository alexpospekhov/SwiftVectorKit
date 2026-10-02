import Foundation
import SwiftVectorCore
import SwiftVectorStorage

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Service for generating symbol documentation, explaining logic, and answering code queries
/// using Apple Foundation Models (SystemLanguageModel & PrivateCloudComputeLanguageModel).
public actor FoundationModelService {
    public init() {}

    public struct StatusReport: Sendable, Codable {
        public let onDeviceAvailable: Bool
        public let pccAvailable: Bool
        public let pccStatus: String
    }

    /// Reports availability status of Apple Foundation Models.
    public func modelStatus() async -> StatusReport {
        var onDevice = false
        var pcc = false
        var pccDesc = "unavailable"

        #if canImport(FoundationModels)
        if #available(macOS 26.0, *) {
            onDevice = SystemLanguageModel.default.isAvailable
        }
        if #available(macOS 27.0, *) {
            let pccModel = PrivateCloudComputeLanguageModel()
            pcc = pccModel.isAvailable
            pccDesc = "\(pccModel.quotaUsage.status)"
        }
        #endif

        return StatusReport(onDeviceAvailable: onDevice, pccAvailable: pcc, pccStatus: pccDesc)
    }

    /// Explains the purpose and implementation of a code chunk using on-device or PCC models.
    public func explain(chunk: CodeChunk) async throws -> String {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, *) {
            if SystemLanguageModel.default.isAvailable {
                let session = LanguageModelSession(
                    model: SystemLanguageModel.default,
                    instructions: "You are an expert Swift engineer. Explain the symbol's logic and architecture concisely."
                )
                let prompt = "Explain symbol `\(chunk.symbolName)` (\(chunk.chunkKind.rawValue)):\n\n```swift\n\(chunk.content)\n```"
                let response = try await session.respond(to: prompt)
                return response.content
            }
        }
        if #available(macOS 27.0, *) {
            let pccModel = PrivateCloudComputeLanguageModel()
            if pccModel.isAvailable {
                let session = LanguageModelSession(
                    model: pccModel,
                    instructions: "You are an expert Swift engineer. Explain the symbol's logic and architecture concisely."
                )
                let prompt = "Explain symbol `\(chunk.symbolName)` (\(chunk.chunkKind.rawValue)):\n\n```swift\n\(chunk.content)\n```"
                let response = try await session.respond(to: prompt)
                return response.content
            }
        }
        #endif

        // Offline deterministic fallback
        var explanation = "Symbol `\(chunk.symbolName)` (\(chunk.chunkKind.rawValue))\n"
        explanation += "File: \(chunk.filePath):\(chunk.startLine)-\(chunk.endLine)\n"
        if !chunk.signature.isEmpty {
            explanation += "Signature: \(chunk.signature)\n"
        }
        if !chunk.docComment.isEmpty {
            explanation += "Documentation: \(chunk.docComment)\n"
        }
        if !chunk.referencedSymbols.isEmpty {
            explanation += "Dependencies: \(chunk.referencedSymbols.joined(separator: ", "))\n"
        }
        return explanation
    }
}
