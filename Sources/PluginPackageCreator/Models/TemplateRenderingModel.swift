//
//  File.swift
//
//
//  Created by Qiwei Li on 1/26/23.
//

import Foundation
import PluginInterface
import Stencil
import SwiftyJSON

class TemplateRenderingModel: ObservableObject {
    @Published var packageInfo: JSON = [:]
    @Published var isGenerating = false
    @Published var packageRepos: [PackageGroup] = []
    @Published var selectedRepo: PackageRepo = .emptyRepo
    @Published var package: Package?
    @Published var schema: JSON?
    
    @Published var isLoading = false
    @Published var downloadedTemplates: [Template] = []

    var fileUtils: FileUtilsProtocol!
    var nsPanel: NSPanelUtilsProtocol!
    private(set) var packageIndexURL: URL = .init(string: "https://scripts.swiftup.net")!
    
    func setup(fileUtils: FileUtilsProtocol, nsPanel: NSPanelUtilsProtocol, store: StoreUtilsProtocol, plugin: any PluginInterfaceProtocol) {
        self.fileUtils = fileUtils
        self.nsPanel = nsPanel
        updatePackageURL(newURL: store.get(forKey: "repo", from: plugin) ?? "")
    }
    
    func updatePackageURL(newURL: String) {
        guard let newURL = URL(string: newURL) else {
            nsPanel.alert(title: "Invalid package url", subtitle: newURL, okButtonText: nil, alertStyle: .critical)
            return
        }
        
        packageIndexURL = newURL
    }
    
    @MainActor
    /**
     The fetchPackageRepo function is used to retrieve package repositories from a remote server.
     It sets the isLoading property to true before making the request, and then to false when the request is finished or an error occurs.
     If an error occurs, the function displays an alert with the error's localized description. The package repositories are decoded from the received data and stored in the packageRepos property.
     */
    func fetchPackageRepo() async {
        do {
            isLoading = true
            let url = packageIndexURL
            let (data, _) = try await URLSession.shared.data(from: url)
            let repos = try JSONDecoder().decode([PackageGroup].self, from: data)
            packageRepos = repos
            isLoading = false
        } catch {
            isLoading = false
            print("err: \(error)")
            nsPanel.alert(title: "Cannot fetch package repo", subtitle: error.localizedDescription, okButtonText: "OK", alertStyle: .critical)
        }
    }
    
    @MainActor
    /**
     The fetchPackage function retrieves detailed information about a specific package from a remote server. It first checks if a repository has been selected and if not, it displays an alert to the user. If a repository is selected, the function sets the isLoading property to true before making the request and to false when the request is finished or an error occurs. If an error occurs, the function displays an alert with the error's localized description. The package information is decoded from the received data and stored in the package property.
     */
    func fetchPackage() async {
        if selectedRepo == .emptyRepo {
            nsPanel.alert(title: "No selected repo", subtitle: "", okButtonText: "OK", alertStyle: .critical)
            return
        }
        
        do {
            isLoading = true
            let (data, _) = try await URLSession.shared.data(from: packageIndexURL.appending(path: selectedRepo.path))
            let package = try JSONDecoder().decode(Package.self, from: data)
            if let schemaPath = package.schema {
                let (schemaData, _) = try await URLSession.shared.data(from: packageIndexURL.appending(path: selectedRepo.path).appending(path: schemaPath))
                schema = try JSON(data: schemaData)
            } else {
                schema = nil
            }
            
            self.package = package
            isLoading = false
        } catch {
            isLoading = false
            nsPanel.alert(title: "Cannot fetch package detail", subtitle: error.localizedDescription, okButtonText: "OK", alertStyle: .critical)
        }
    }
    
    @MainActor
    func renderOutputPath(template: Template) -> String? {
        return template.getOutputPath(packageInfo: packageInfo)
    }
    
    @MainActor
    /**
     The render function is used to create a new project based on a selected package.
     It first checks if a package has been selected and if not, it displays an alert to the user.
     If a package is selected, it checks if there are any previous downloads and if there are, it prompts the user to confirm if they want to override the existing content.
     If the user confirms, it clears the previous downloads. Then it prompts the user to confirm if they want to create the project now.
     If the user confirms, it starts generating the templates for the package by using the "render" function of each template and passing packageInfo and baseURL as arguments.
     For each template it generates, it appends it to the downloadedTemplates array and it writes the content to the output path that is generated by the function renderOutputPath. If there is an error in generating template to path, it will display an alert to the user.
     It sets the isGenerating property to true before starting the process and to false when the process is finished or an error occurs. If an error occurs, it throws the error.
     */
    func render(before: (Package, JSON) async throws -> Void, after: (Package, JSON) async throws -> Void) async throws {
        guard let package = package else {
            nsPanel.alert(title: "No package found", subtitle: "", okButtonText: "OK", alertStyle: .critical)
            return
        }
        
        if !downloadedTemplates.isEmpty {
            let confirmed = nsPanel.confirm(title: "Previous downloads existed", subtitle: "This will override existing contents", confirmButtonText: "Confirm", cancelButtonText: "Cancel", alertStyle: .informational)
            if !confirmed {
                return
            }
            downloadedTemplates = []
        }
        
        do {
            isGenerating = true
            let confirmed = nsPanel.confirm(title: "Create project now?", subtitle: "This will override any existing content", confirmButtonText: "Create!", cancelButtonText: "Cancel", alertStyle: .informational)

            if !confirmed {
                return
            }
            
            try await before(package, packageInfo)
            for template in package.templates.filter({ $0.included }) {
                downloadedTemplates.append(template)
                let content = try await render(template: template)
                guard let outputPath = renderOutputPath(template: template) else {
                    nsPanel.alert(title: "Error in generating template to path", subtitle: "", okButtonText: "OK", alertStyle: .critical)
                    continue
                }
                try fileUtils.writeFile(at: outputPath, with: content)
            }
            try await after(package, packageInfo)
            isGenerating = false
        } catch {
            isGenerating = false
            throw error
        }
    }
    
    func updateInclude(template: Template, value: Bool) {
        if let index = package?.templates.firstIndex(of: template) {
            package?.templates[index].included = value
        }
    }
    
    func render(template: Template) async throws -> String {
        let content = try await template.render(packageInfo: packageInfo, baseURL: packageIndexURL.appending(path: selectedRepo.path))
        return content
    }
}
