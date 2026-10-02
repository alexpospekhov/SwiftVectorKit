import Foundation
import Accelerate
import SwiftVectorCore

/// High-performance SIMD vector distance calculations using Apple Accelerate framework (vDSP).
/// Provides sub-millisecond batch cosine similarity over thousands of vectors.
public struct AccelerateSIMDDistance: Sendable {
    public init() {}

    // MARK: - Float32 (Core ML & Neural Engine Native)

    /// Computes cosine similarity between two 32-bit floating point vectors.
    public static func cosineSimilarity(a: [Float], b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0.0 }
        var dot: Float = 0.0
        var aNorm: Float = 0.0
        var bNorm: Float = 0.0
        let len = vDSP_Length(a.count)

        vDSP_dotpr(a, 1, b, 1, &dot, len)
        vDSP_svesq(a, 1, &aNorm, len)
        vDSP_svesq(b, 1, &bNorm, len)

        let denom = sqrt(aNorm) * sqrt(bNorm)
        guard denom > 0 else { return 0.0 }
        return dot / denom
    }

    /// Batch calculates cosine similarity between a single query and a matrix of target vectors.
    public static func cosineSimilarity(query: [Float], targets: [[Float]]) -> [Float] {
        guard !query.isEmpty, !targets.isEmpty else { return [] }
        var results = [Float](repeating: 0.0, count: targets.count)
        var qNorm: Float = 0.0
        let len = vDSP_Length(query.count)
        vDSP_svesq(query, 1, &qNorm, len)
        let qSqrt = sqrt(qNorm)
        guard qSqrt > 0 else { return results }

        for (i, target) in targets.enumerated() {
            guard target.count == query.count else { continue }
            var dot: Float = 0.0
            var tNorm: Float = 0.0
            vDSP_dotpr(query, 1, target, 1, &dot, len)
            vDSP_svesq(target, 1, &tNorm, len)
            let tSqrt = sqrt(tNorm)
            if tSqrt > 0 {
                results[i] = dot / (qSqrt * tSqrt)
            }
        }
        return results
    }

    // MARK: - Float64 (Double Precision)

    /// Computes cosine similarity between two 64-bit floating point vectors.
    public static func cosineSimilarity(a: [Double], b: [Double]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return 0.0 }
        var dot: Double = 0.0
        var aNorm: Double = 0.0
        var bNorm: Double = 0.0
        let len = vDSP_Length(a.count)

        vDSP_dotprD(a, 1, b, 1, &dot, len)
        vDSP_svesqD(a, 1, &aNorm, len)
        vDSP_svesqD(b, 1, &bNorm, len)

        let denom = sqrt(aNorm) * sqrt(bNorm)
        guard denom > 0 else { return 0.0 }
        return dot / denom
    }

    /// Batch calculates cosine similarity between a single query and a matrix of target vectors.
    public static func cosineSimilarity(query: [Double], targets: [[Double]]) -> [Double] {
        guard !query.isEmpty, !targets.isEmpty else { return [] }
        var results = [Double](repeating: 0.0, count: targets.count)
        var qNorm = 0.0
        let len = vDSP_Length(query.count)
        vDSP_svesqD(query, 1, &qNorm, len)
        let qSqrt = sqrt(qNorm)
        guard qSqrt > 0 else { return results }

        for (i, target) in targets.enumerated() {
            guard target.count == query.count else { continue }
            var dot = 0.0
            var tNorm = 0.0
            vDSP_dotprD(query, 1, target, 1, &dot, len)
            vDSP_svesqD(target, 1, &tNorm, len)
            let tSqrt = sqrt(tNorm)
            if tSqrt > 0 {
                results[i] = dot / (qSqrt * tSqrt)
            }
        }
        return results
    }
}
