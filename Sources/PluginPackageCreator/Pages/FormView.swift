//
//  SwiftUIView.swift
//  
//
//  Created by Qiwei Li on 1/26/23.
//

import SwiftUI
import PluginInterface

struct FormView: View {
    @EnvironmentObject var model: RenderingModel
    
    let workspace: URL?
    let nsPanelUtils: NSPanelUtilsProtocol
    
    
    var body: some View {
        Form {
            TextField("Plugin Name", text: $model.packageInfo.name)
            TextField("Display Name", text: $model.packageInfo.displayName)
            TextField("BundleIdentifier", text: $model.packageInfo.bundleIdentifier)
            TextField("Author", text: $model.packageInfo.author)
            TextField("Short Description", text: $model.packageInfo.shortDescription)
            TextField("Repository", text: $model.packageInfo.repository)
            
            HStack {
                Spacer()
                Button {
                    render()
                } label: {
                    if model.isGenerating {
                        ProgressView()
                    } else {
                        Text("Generate project")
                    }
                }
                .disabled(workspace == nil || model.packageInfo.isDisabled)
            }
        }
    }
    
    func render() {
        do {
            try model.render()
        } catch {
            nsPanelUtils.alert(title: "Cannot generate project", subtitle: error.localizedDescription, okButtonText: "OK", alertStyle: .critical)
        }
    }
}
