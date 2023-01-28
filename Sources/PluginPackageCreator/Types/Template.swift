//
//  Template.swift
//
//
//  Created by Qiwei Li on 1/26/23.
//

import Foundation
import Stencil
import SwiftyJSON
import CodeEditLanguages

enum TemplateErrors: LocalizedError {
    case invalidTemplateContent
    
    var errorDescription: String? {
        switch self {
            case .invalidTemplateContent:
                return "The given template is invalid"
        }
    }
}

struct Template: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var description: String
    var outputFilePath: String
    var shouldRender: Bool {
        get {
            name.hasSuffix(".j2")
        }
    }
    
    enum CodingKeys: CodingKey {
        case name
        case description
        case outputFilePath
    }
    
    func templateURL(baseURL: URL) -> URL {
        return baseURL.appending(path: "files").appending(path: self.name)
    }
    
    static func ==(lhs: Template, rhs: Template) -> Bool {
        return lhs.name == rhs.name && lhs.outputFilePath == rhs.outputFilePath
    }
    
    func getOutputPath(packageInfo: JSON) -> String? {
        let environment = Environment()
        let renderedContent = try? environment.renderTemplate(string: outputFilePath, context: packageInfo.dictionaryValue)
        return renderedContent
    }


    @MainActor
    func render(packageInfo: JSON, baseURL: URL) async throws -> String {
        let environment = Environment()
        let (data, _) = try await URLSession.shared.data(from: baseURL.appending(path: "files").appending(path: name))
        guard let template = String(data: data, encoding: .utf8) else {
            throw TemplateErrors.invalidTemplateContent
        }
        
        if !shouldRender {
            return template
        }
        
        let renderedContent = try environment.renderTemplate(string: template, context: packageInfo.dictionaryValue)
        return renderedContent
    }
}


extension Template {
    var language: CodeLanguage {
        get {
            .detectLanguageFrom(url: URL(filePath: outputFilePath))
        }
    }
}
