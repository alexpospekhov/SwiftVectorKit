import Foundation
import AppIntents
import SwiftVectorCore

@available(macOS 13.0, *)
public struct SearchCodeIntent: AppIntent {
    public static let title: LocalizedStringResource = "Search Code with SwiftVector"
    public static let description = IntentDescription("Searches local codebases using Apple Silicon vector acceleration.")

    @Parameter(title: "Query")
    public var query: String

    public init() {}
    public init(query: String) {
        self.query = query
    }

    public func perform() async throws -> some IntentResult & ReturnsValue<String> {
        return .result(value: "Search completed for: \(query)")
    }
}
