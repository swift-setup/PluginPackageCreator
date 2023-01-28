import PluginInterface
import SwiftUI
import Stencil

struct PluginPackageCreator: PluginInterfaceProtocol {
    public var manifest: ProjectManifest = ProjectManifest(displayName: "PluginPackageCreator", bundleIdentifier: "com.sirilee.PluginPackageCreator", author: "sirily11", shortDescription: "Setup using templates", repository: "https://github.com/swift-setup/PluginPackageCreator", keywords: ["creator", "swift-ui"])
    
    
    let fileUtils: FileUtilsProtocol
    let nsPanelUtils: NSPanelUtilsProtocol
    
    public init(fileUtils: FileUtilsProtocol, nsPanelUtils: NSPanelUtilsProtocol) {
        self.fileUtils = fileUtils
        self.nsPanelUtils = nsPanelUtils
    }
    
    public var id = UUID()
    
    public var view: some View {
       CreationView(fileUtils: fileUtils, nsPanelUtils: nsPanelUtils)
            .padding()
    }
}


@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(PluginackageCreatorBuilder()).toOpaque()
}

public final class PluginackageCreatorBuilder: PluginBuilder {
    public override func build(fileUtils: FileUtilsProtocol, nsPanelUtils: NSPanelUtilsProtocol, storeUtils: StoreUtilsProtocol) -> any PluginInterfaceProtocol {
        PluginPackageCreator(fileUtils: fileUtils, nsPanelUtils: nsPanelUtils)
    }
}

