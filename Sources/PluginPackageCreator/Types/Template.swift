//
//  Template.swift
//
//
//  Created by Qiwei Li on 1/26/23.
//

import Foundation
import Stencil
import SwiftyJSON
import SwiftUI

enum TemplateErrors: LocalizedError {
    case invalidTemplateContent
    
    var errorDescription: String? {
        switch self {
            case .invalidTemplateContent:
                return "The given template is invalid"
        }
    }
}

struct ShouldInclude: Codable {
    var allOf: [String:Bool]?
    var anyOf: [String:Bool]?
    
    public init(allOf: [String : Bool]? = nil, anyOf: [String : Bool]? = nil) {
        self.allOf = allOf
        self.anyOf = anyOf
    }
    
    public func shouldInclude(values: JSON) -> Bool {
        // If there is no anyOf or allOf, then it should be included
        if allOf == nil && anyOf == nil {
            return true
        }

        // If there is allOf, then all of the values should be true
        if allOf != nil  {
            return checkAllOf(values: values)
        }


        // If there is anyOf, then any of the values should be true
        if anyOf != nil  {
            return checkAnyOf(values: values)
        }
          
        return true
    }

    internal func checkAllOf(values: JSON) -> Bool {
        guard let allOf = allOf else {
            return true
        }
        
        for (key, value) in allOf {
            if values[key].boolValue != value {
                return false
            }
        }
        return true
    }

    internal func checkAnyOf(values: JSON) -> Bool {
        guard let anyOf = anyOf else {
            return true
        }
        
        for (key, value) in anyOf {
            if values[key].boolValue == value {
                return true
            }
        }
        return false
    }
}

struct Template: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var description: String
    var outputFilePath: String
    var shouldInclude: ShouldInclude?
    /**
     Indicates whether this file should be included in the generated file list.
     */
    var included: Bool = true
    /**
     Indicates whether the rendering engine should be used to render the output.
     */
    var shouldRender: Bool {
        get {
            name.hasSuffix(".j2")
        }
    }
    
    enum CodingKeys: CodingKey {
        case name
        case description
        case outputFilePath
        case shouldInclude
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
