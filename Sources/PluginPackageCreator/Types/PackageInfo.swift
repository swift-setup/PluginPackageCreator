//
//  File.swift
//
//
//  Created by Qiwei Li on 1/26/23.
//

import Foundation
import PluginInterface

struct PackageInfo: ProjectManifestProtocol {
    var displayName: String

    var bundleIdentifier: String

    var author: String

    var shortDescription: String

    var repository: String

    var keywords: [String]

    var systemImageName: String?

    var name: String

    var isDisabled: Bool {
        if name.contains(" ") {
            return true
        }
        
        guard let _ = URL(string: repository) else {
            return false
        }
        
        
        return name.isEmpty || displayName.isEmpty || bundleIdentifier.isEmpty || author.isEmpty || shortDescription.isEmpty || repository.isEmpty
    }
}
