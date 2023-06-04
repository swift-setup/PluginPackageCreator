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
    
    @StateObject private var model = RenderingModel()
    @State var workspace: URL?
    
    var body: some View {
        VStack {
            HStack {
                Text("Repo")
                Spacer()
                Menu(model.selectedRepo.title) {
                    ForEach(model.packageRepos) { item in
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
                FileListView(templates: model.package?.templates ?? [], downloaded: model.downloadedTemplates)
                    .tabItem {
                        Text("Files to be generated")
                    }
            }
            .onAppear {
                model.setup(fileUtils: fileUtils, nsPanel: nsPanelUtils, store: store, plugin: plugin)
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
    
    func render() async {
        do {
            try await model.render()
        } catch {
            nsPanelUtils.alert(title: "Cannot generate project", subtitle: error.localizedDescription, okButtonText: "OK", alertStyle: .critical)
        }
    }
}
