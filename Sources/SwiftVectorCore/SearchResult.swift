import Foundation

/// Request parameters for hybrid semantic code search.
public struct SearchQuery: Sendable, Codable, Equatable {
    public let text: String
    public let limit: Int
    public let filterFilePrefix: String?
    public let includeImpact: Bool

    public init(
        text: String,
        limit: Int = 10,
        filterFilePrefix: String? = nil,
        includeImpact: Bool = false
    ) {
        self.text = text
        self.limit = limit
        self.filterFilePrefix = filterFilePrefix
        self.includeImpact = includeImpact
    }
}

/// Unified result from hybrid dense vector + lexical search.
public struct SearchResult: Identifiable, Sendable, Codable, Equatable {
    public let id: String
    public let chunk: CodeChunk
    public let vectorScore: Double
    public let lexicalScore: Double
    public let fusedScore: Double
    public let blastRadius: BlastRadiusMetric?

    public init(
        id: String = UUID().uuidString.lowercased(),
        chunk: CodeChunk,
        vectorScore: Double,
        lexicalScore: Double,
        fusedScore: Double,
        blastRadius: BlastRadiusMetric? = nil
    ) {
        self.id = id
        self.chunk = chunk
        self.vectorScore = vectorScore
        self.lexicalScore = lexicalScore
        self.fusedScore = fusedScore
        self.blastRadius = blastRadius
    }
}

/// Compiler-verified blast radius metric from IndexStore/SCIP.
public struct BlastRadiusMetric: Sendable, Codable, Equatable {
    public let riskLevel: RiskLevel
    public let totalCallers: Int
    public let affectedFilesCount: Int
    public let isProtocolRequirement: Bool

    public enum RiskLevel: String, Sendable, Codable, Equatable {
        case low
        case medium
        case high
    }

    public init(
        riskLevel: RiskLevel,
        totalCallers: Int,
        affectedFilesCount: Int,
        isProtocolRequirement: Bool = false
    ) {
        self.riskLevel = riskLevel
        self.totalCallers = totalCallers
        self.affectedFilesCount = affectedFilesCount
        self.isProtocolRequirement = isProtocolRequirement
    }
}
