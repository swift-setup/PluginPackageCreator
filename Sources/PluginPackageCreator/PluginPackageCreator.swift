import PluginInterface
import SwiftUI
import Stencil

struct PluginPackageCreator: PluginInterfaceProtocol {
    public var manifest: ProjectManifest = ProjectManifest(displayName: "PluginPackageCreator", bundleIdentifier: "com.sirilee.PluginPackageCreator", author: "sirily11", shortDescription: "Setup using templates", repository: "https://github.com/swift-setup/PluginPackageCreator", keywords: ["creator", "swift-ui"])
    
    let fileUtils: FileUtilsProtocol
    let nsPanelUtils: NSPanelUtilsProtocol
    let store: StoreUtilsProtocol
    
    public init(fileUtils: FileUtilsProtocol, nsPanelUtils: NSPanelUtilsProtocol, store: StoreUtilsProtocol) {
        self.fileUtils = fileUtils
        self.nsPanelUtils = nsPanelUtils
        self.store = store
    }
    
    public var id = UUID()
    
    public var view: some View {
        CreationView(fileUtils: fileUtils, nsPanelUtils: nsPanelUtils, store: store, plugin: self)
            .padding()
    }
    
    var settings: some View {
        SettingsView(store:store, plugin: self)
    }
}


@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(PluginackageCreatorBuilder()).toOpaque()
}

public final class PluginackageCreatorBuilder: PluginBuilder {
    public override func build(fileUtils: FileUtilsProtocol, nsPanelUtils: NSPanelUtilsProtocol, storeUtils: StoreUtilsProtocol) -> any PluginInterfaceProtocol {
        PluginPackageCreator(fileUtils: fileUtils, nsPanelUtils: nsPanelUtils, store: storeUtils)
    }
}

