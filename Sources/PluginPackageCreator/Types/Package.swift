//
//  File.swift
//
//
//  Created by Qiwei Li on 1/27/23.
//

import Foundation

struct PackageGroup: Codable, Hashable {
    var name: String
    var children: [PackageGroup]?
    var menus: [PackageRepo]?
}

struct PackageRepo: Codable, Hashable {
    var title: String
    var path: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    static func ==(lhs: PackageRepo, rhs: PackageRepo) -> Bool {
        return lhs.title == rhs.title
    }

    static var emptyRepo: PackageRepo = .init(title: "Pick a repo", path: "")
}

struct Package: Codable {
    var title: String
    var description: String
    var templates: [Template]
    var schema: String?
    var beforeScript: PackageScript?
    var afterScript: PackageScript?

    /**
        *  Check if the script is finished
     */
    var isScriptFinished: Bool {
        if let beforeScript = beforeScript {
            if beforeScript.loading {
                return false
            }
        }

        if let afterScript = afterScript {
            if afterScript.loading {
                return false
            }
        }

        return true
    }

    var isScriptSuccess: Bool {
        if let beforeScript = beforeScript {
            if !beforeScript.success {
                return false
            }
        }

        if let afterScript = afterScript {
            if !afterScript.success {
                return false
            }
        }

        return true
    }

    var isScriptError: Bool {
        if let beforeScript = beforeScript {
            if beforeScript.error != nil {
                return true
            }
        }

        if let afterScript = afterScript {
            if afterScript.error != nil {
                return true
            }
        }

        return false
    }
}
