//
//  ScriptModel.swift
//
//
//  Created by Qiwei Li on 6/5/23.
//

import Foundation
import PluginInterface
import SwiftyJSON

class ScriptRenderingModel: ObservableObject {
    var fileUtils: FileUtilsProtocol!
    var nsPanel: NSPanelUtilsProtocol!

    func setup(fileUtils: FileUtilsProtocol, nsPanel: NSPanelUtilsProtocol, store: StoreUtilsProtocol) {
        self.fileUtils = fileUtils
        self.nsPanel = nsPanel
    }

    func downloadScript(using package: Package, with repoURL: URL) async throws {
        if let beforeScript = package.beforeScript {
            guard let script = try await beforeScript.download(with: repoURL) else {
                return
            }
            try fileUtils.writeFile(at: "before_script", with: script)
        }

        if let afterScript = package.afterScript {
            guard let script = try await afterScript.download(with: repoURL) else {
                return
            }
            try fileUtils.writeFile(at: "after_script", with: script)
        }
    }

    @MainActor
    func run(withPackage package: Package, of type: ScriptType, using packageInfo: JSON) async throws -> String? {
        guard let workdir = fileUtils.currentWorkSpace else {
            throw ScriptError.missingPackage
        }

        if type == .before {
            return try await package.beforeScript?.run(packageInfo: packageInfo, at: workdir)
        } else {
            return try await package.afterScript?.run(packageInfo: packageInfo, at: workdir)
        }
    }
}
