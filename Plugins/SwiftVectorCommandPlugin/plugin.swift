import PackagePlugin

@main
struct SwiftVectorCommandPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        // Invoked on-demand via Product -> Run SwiftVectorCommandPlugin in Xcode
        let executable = try context.tool(named: "swiftvector").url
        print("[SwiftVectorCommandPlugin] Executing full workspace indexing: \(executable.path)")
    }
}
