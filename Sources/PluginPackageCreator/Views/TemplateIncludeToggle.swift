//
//  SwiftUIView.swift
//  
//
//  Created by Qiwei Li on 1/29/23.
//

import SwiftUI

struct TemplateIncludeToggle: View {
    @EnvironmentObject var model: RenderingModel
    
    let template: Template
    @State var isOn: Bool
    
    init(template: Template) {
        self.template = template
        _isOn = .init(initialValue: template.included)
    }
    
    
    var body: some View {
        Toggle("", isOn: $isOn)
            .onChange(of: isOn) { value in
                model.updateInclude(template: template, value: value)
            }
    }
}
