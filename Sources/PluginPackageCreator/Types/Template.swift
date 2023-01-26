//
//  File.swift
//
//
//  Created by Qiwei Li on 1/26/23.
//

import Foundation
import Stencil

struct Template: Identifiable {
    var id = UUID()
    var templateURL: URL
    var outputFilePath: String
    var packageInfo: [String: PackageInfo]

    func render() throws -> String {
        let environment = Environment()
        let template = try String(contentsOf: templateURL)
        let renderedContent = try environment.renderTemplate(string: template, context: packageInfo)
        return renderedContent
    }
}
