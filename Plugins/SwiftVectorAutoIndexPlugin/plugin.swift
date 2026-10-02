import PackagePlugin

@main
struct SwiftVectorAutoIndexPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        // Automatically invoked during every Cmd+B build in Xcode
        let executable = try context.tool(named: "swiftvector").url
        return [
            .prebuildCommand(
                displayName: "SwiftVectorKit Live AST Indexing & Diagnostic Check",
                executable: executable,
                arguments: ["index", context.package.directoryURL.path],
                outputFilesDirectory: context.pluginWorkDirectoryURL
            )
        ]
    }
}
