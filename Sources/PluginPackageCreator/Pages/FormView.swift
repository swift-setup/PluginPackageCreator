//
//  SwiftUIView.swift
//
//
//  Created by Qiwei Li on 1/26/23.
//

import PluginInterface
import SwiftUI
import SwiftUIJsonSchemaForm
import SwiftyJSON

struct FormView: View {
    @EnvironmentObject var model: TemplateRenderingModel
    
    let workspace: URL?
    let nsPanelUtils: NSPanelUtilsProtocol
    @State var data: JSON = [:]
    
    var body: some View {
        if model.isLoading {
            VStack {
                ProgressView()
            }
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            if let package = model.package {
                                Text(package.title).font(.title)
                                Text(package.description).font(.subheadline)
                            }
                        }
                        Spacer()
                        Button("Refresh") {
                            Task {
                                await model.fetchPackage()
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if let schema = model.schema {
                        SwiftUIJsonSchemaForm.FormView(jsonSchema: schema, values: model.packageInfo) { values in
                            updateIncludes(values: values)
                        }
                    }
                }
                .padding()
                .onAppear {
                    print("Init", model.packageInfo.description)
                }
            }
        }
    }
    
    @MainActor
    func updateIncludes(values: JSON) {
        print("UpdateIncludes", model.packageInfo, values)
        model.packageInfo = values
        print(model.packageInfo.description)
        model.package?.templates.forEach { template in
            if let value = template.shouldInclude?.shouldInclude(values: values) {
                model.updateInclude(template: template, value: value)
            }
        }
    }
}
