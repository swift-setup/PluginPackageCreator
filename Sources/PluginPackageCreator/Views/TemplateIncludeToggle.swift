//
//  SwiftUIView.swift
//
//
//  Created by Qiwei Li on 1/29/23.
//

import SwiftUI
import SwiftyJSON

struct TemplateIncludeToggle: View {
    @EnvironmentObject var model: TemplateRenderingModel

    let template: Template
    let includedTemplates: [Template]
    @State var isOn: Bool = false

    var body: some View {
        Toggle("", isOn: self.$isOn)
            .onChange(of: self.isOn) { value in
                self.model.updateInclude(template: self.template, value: value)
            }
            .onAppear {
                if let _ = includedTemplates.first(where: { $0.id == template.id }) {
                    isOn = true
                } else {
                    isOn = false
                }
            }
    }
}
