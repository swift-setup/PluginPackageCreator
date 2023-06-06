//
//  Script.swift
//
//
//  Created by Qiwei Li on 6/6/23.
//

import Foundation
import Stencil
import SwiftyJSON

enum ScriptError: LocalizedError {
    case missingPackage
    case runCommandError(String)

    var errorDescription: String? {
        switch self {
        case .missingPackage:
            return "Missing package"
        case .runCommandError(let error):
            return error
        }
    }
}

enum ScriptType {
    case before
    case after
}

enum Language: String, Codable {
    case swift
    case python = "python3"
}

struct PackageScript: Codable {
    var scriptPath: String?
    var cmd: String?
    var language: Language?
    var loading: Bool = false
    var success: Bool = false
    var error: Error? = nil
    var output: String = ""

    enum CodingKeys: CodingKey {
        case scriptPath
        case cmd
        case language
    }

    mutating func resetStatus() {
        loading = false
        success = false
        error = nil
        output = ""
    }

    mutating func setError(error: Error) {
        self.error = error
        success = false
        loading = false
    }

    mutating func setSuccess(output: String?) {
        if let output = output {
            self.output = output
        }
        success = true
        loading = false
    }

    func renderCommand(packageInfo: JSON) throws -> String? {
        let environment = Environment()
        guard let cmd = cmd else {
            return nil
        }
        let renderedContent = try environment.renderTemplate(string: cmd, context: packageInfo.dictionaryObject!)
        return renderedContent
    }

    func run(packageInfo: JSON, at dir: URL) async throws -> String {
        if let renderedCommand = try renderCommand(packageInfo: packageInfo) {
            return try run(cmd: renderedCommand, currentDir: dir)
        }

        return ""
    }

    func download(with url: URL) async throws -> String? {
        if let scriptPath = scriptPath {
            let downloadURL = url.appending(component: scriptPath)
            let (data, _) = try await URLSession.shared.data(from: downloadURL)
            guard let template = String(data: data, encoding: .utf8) else {
                throw TemplateErrors.invalidTemplateContent
            }
            return template
        }
        return nil
    }

    func run(cmd: String, currentDir: URL) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        // we need --login to make sure the PATH is correct
        process.arguments = ["--login", "-c", cmd]
        // set the current working directory to the project root
        process.currentDirectoryURL = currentDir
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)
        let error = String(data: errorData, encoding: .utf8)

        if let error = error, !error.isEmpty {
            throw ScriptError.runCommandError(error)
        }

        return output ?? ""
    }
}
