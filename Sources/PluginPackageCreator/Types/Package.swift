//
//  File.swift
//
//
//  Created by Qiwei Li on 1/27/23.
//

import Foundation

struct PackageGroup: Codable, Hashable, Identifiable {
    let id = UUID()
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
}
