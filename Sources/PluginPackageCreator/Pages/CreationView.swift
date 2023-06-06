//
//  File.swift
//
//
//  Created by Qiwei Li on 1/26/23.
//

import Foundation
import PluginInterface
import SwiftUI

struct CreationView: View {
    let fileUtils: FileUtilsProtocol
    let nsPanelUtils: NSPanelUtilsProtocol
    let store: StoreUtilsProtocol
    let plugin: any PluginInterfaceProtocol
    
    @StateObject private var model = TemplateRenderingModel()
    @StateObject private var scriptModel = ScriptRenderingModel()
    @State var workspace: URL?
    
    var body: some View {
        VStack {
            HStack {
                Text("Repo")
                Spacer()
                Menu(model.selectedRepo.title) {
                    ForEach(model.packageRepos, id: \.name) { item in
                        MenuItemView(item: item)
                    }
                }
                .frame(maxWidth: 300)
                Spacer()
                Button("Refresh repos") {
                    Task {
                        let url: String? = store.get(forKey: "repo", from: plugin)
                        if let url = url {
                            model.updatePackageURL(newURL: url)
                        }
                        await model.fetchPackageRepo()
                    }
                }
            }
            HStack {
                Text("Current workspace")
                Spacer()
                if let workspace = workspace {
                    Text(workspace.absoluteString)
                }
                Button("Open workspace") {
                    openWorkspace()
                }
            }
            TabView {
                FormView(workspace: workspace, nsPanelUtils: nsPanelUtils)
                    .tabItem {
                        Text("General info")
                    }
                
                ScriptsView(package: model.package)
                    .tabItem {
                        Text("Scripts")
                    }
                
                FileListView(templates: model.package?.templates ?? [], downloaded: model.downloadedTemplates)
                    .tabItem {
                        Text("Files to be generated")
                    }
            }
            .onAppear {
                model.setup(fileUtils: fileUtils, nsPanel: nsPanelUtils, store: store, plugin: plugin)
                scriptModel.setup(fileUtils: fileUtils, nsPanel: nsPanelUtils, store: store)
            }
            
            HStack {
                Spacer()
                Button {
                    Task {
                        await render()
                    }
                } label: {
                    if model.isGenerating {
                        ProgressView()
                    } else {
                        Text("Generate project")
                    }
                }
                .disabled(workspace == nil || model.selectedRepo == .emptyRepo)
            }
        }
        .environmentObject(model)
        .onChange(of: model.selectedRepo, perform: { newValue in
            if newValue != .emptyRepo {
                Task {
                    await model.fetchPackage()
                }
            }
        })
        .task {
            await model.fetchPackageRepo()
        }
    }
    
    func openWorkspace() {
        do {
            workspace = try fileUtils.updateCurrentWorkSpace()
        } catch {
            nsPanelUtils.alert(title: "Cannot open workspace", subtitle: error.localizedDescription, okButtonText: "OK", alertStyle: .critical)
        }
    }
    
    @MainActor
    func render() async {
        do {
            try await model.render(before: { package, packageInfo in
                do {
                    model.package?.beforeScript?.resetStatus()
                    let output = try await scriptModel.run(withPackage: package, of: .before, using: packageInfo)
                    model.package?.beforeScript?.setSuccess(output: output)
                } catch {
                    model.package?.beforeScript?.setError(error: error)
                    throw error
                }
            }, after: { package, packageInfo in
                do {
                    model.package?.beforeScript?.resetStatus()
                    let output = try await scriptModel.run(withPackage: package, of: .after, using: packageInfo)
                    model.package?.afterScript?.setSuccess(output: output)
                } catch {
                    model.package?.afterScript?.setError(error: error)
                    throw error
                }
            })
        } catch {
            nsPanelUtils.alert(title: "Cannot generate project", subtitle: error.localizedDescription, okButtonText: "OK", alertStyle: .critical)
        }
    }
}
