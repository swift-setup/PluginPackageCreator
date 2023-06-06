//
//  SwiftUIView.swift
//
//
//  Created by Qiwei Li on 6/6/23.
//

import SwiftUI

struct ScriptsView: View {
    let package: Package?

    var body: some View {
        VStack(alignment: .leading) {
            if let beforeScript = package?.beforeScript {
                Section("Before script") {
                    PackageRepoScriptView(script: beforeScript)
                }
            }

            if let afterScript = package?.afterScript {
                Section("After script") {
                    PackageRepoScriptView(script: afterScript)
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct PackageRepoScriptView: View {
    let script: PackageScript
    @EnvironmentObject var model: TemplateRenderingModel
    @State var cmd: String = ""

    var body: some View {
        HStack {
            if let scriptPath = script.scriptPath {
                Text(scriptPath)
            }
            if let _ = script.cmd {
                Text(cmd)
            }
            Spacer()
            if let language = script.language {
                Text(language.rawValue.capitalized)
            }
            if script.loading {
                ProgressView()
            } else {
                if script.success {
                    PopoverView {
                        Image(systemName: "checkmark.diamond.fill")
                            .foregroundColor(.green)
                    } popover: {
                        Text(script.output)
                    }
                }

                if let error = script.error {
                    PopoverView {
                        Image(systemName: "xmark.shield.fill")
                            .foregroundColor(.red)
                    } popover: {
                        Text(error.localizedDescription)
                    }
                }
            }
        }
        .onReceive(model.$packageInfo, perform: { info in
            if let cmd = try? script.renderCommand(packageInfo: info) {
                self.cmd = cmd
            }
        })
        .padding()
        .background(
            Color.gray
                .opacity(0.1)
                .cornerRadius(10)
        )
    }
}

struct ScriptsView_Previews: PreviewProvider {
    static var previews: some View {
        ScriptsView(package: .init(title: "Hello", description: "world", templates: [], beforeScript: .init(cmd: "Hello")))
    }
}
