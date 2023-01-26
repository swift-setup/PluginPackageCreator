//
//  File.swift
//  
//
//  Created by Qiwei Li on 1/26/23.
//

import Foundation
import SwiftUI
import PluginInterface

struct CreationView: View {
    let fileUtils: FileUtilsProtocol
    let nsPanelUtils: NSPanelUtilsProtocol
    
    @StateObject private var model = RenderingModel()
    @State var workspace: URL?
    
    var body: some View {
        VStack {
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
                FileListView(templates: model.templates)
                    .tabItem {
                        Text("Files to be generated")
                    }
            }
            .onAppear {
                model.setup(fileUtils: fileUtils, nsPanel: nsPanelUtils)
            }
        }
        .environmentObject(model)
    }
    
    func openWorkspace() {
        do {
            workspace = try fileUtils.updateCurrentWorkSpace()
        } catch {
            nsPanelUtils.alert(title: "Cannot open workspace", subtitle: error.localizedDescription, okButtonText: "OK", alertStyle: .critical)
        }
    }
    
}
