//
//  File.swift
//
//
//  Created by Qiwei Li on 1/26/23.
//

import Foundation
import PluginInterface
import Stencil

class RenderingModel: ObservableObject {
    @Published var packageInfo = PackageInfo(displayName: "", bundleIdentifier: "", author: "", shortDescription: "", repository: "", keywords: [], name: "")
    @Published var isGenerating = false

    var fileUtils: FileUtilsProtocol!
    var nsPanel: NSPanelUtilsProtocol!
    var templates: [Template] {
        let context: [String: PackageInfo] = [
            "package": packageInfo,
        ]
        let packageSwiftTemplate = Bundle.module.url(forResource: "Package.swift", withExtension: "j2")
        let mainPackageTemplate = Bundle.module.url(forResource: "MainPackage.swift", withExtension: "j2")
        let gitIgnoreTemplate = Bundle.module.url(forResource: "GitIgnore", withExtension: "j2")
        let readmeTemplate = Bundle.module.url(forResource: "Readme.md", withExtension: "j2")

        let templates: [Template] = [
            Template(templateURL: packageSwiftTemplate!, outputFilePath: "Package.swift", packageInfo: context),
            Template(templateURL: mainPackageTemplate!, outputFilePath: "Sources/\(packageInfo.name.capitalized)/\(packageInfo.name.capitalized).swift", packageInfo: context),
            Template(templateURL: gitIgnoreTemplate!, outputFilePath: ".gitignore", packageInfo: context),
            Template(templateURL: readmeTemplate!, outputFilePath: "README.md", packageInfo: context),
        ]
        return templates
    }

    func setup(fileUtils: FileUtilsProtocol, nsPanel: NSPanelUtilsProtocol) {
        self.fileUtils = fileUtils
        self.nsPanel = nsPanel
    }

    @MainActor
    func render() throws {
        do {
            isGenerating = true
            let confirmed = nsPanel.confirm(title: "Create project now?", subtitle: "This will override any existing content", confirmButtonText: "Create!", cancelButtonText: "Cancel", alertStyle: .informational)

            if !confirmed {
                return
            }

            for template in templates {
                let content = try template.render()
                try fileUtils.writeFile(at: template.outputFilePath, with: content)
            }
            isGenerating = false
        } catch {
            isGenerating = false
            throw error
        }
    }
}
