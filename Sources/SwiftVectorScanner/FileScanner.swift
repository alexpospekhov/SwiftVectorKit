import Foundation
import SwiftVectorCore

public struct FileScanner: Sendable {
    public init() {}
    public func scan(directory: URL) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
            return []
        }
        var files: [URL] = []
        for case let url as URL in enumerator {
            let ext = url.pathExtension.lowercased()
            if ["swift", "metal", "c", "h", "cpp", "py", "rs", "go", "ts", "js"].contains(ext) {
                files.append(url)
            }
        }
        return files
    }
}
