//
//  SwiftUIView.swift
//  
//
//  Created by Qiwei Li on 1/29/23.
//

import SwiftUI
import SwiftyJSON

struct TemplateIncludeToggle: View {
    @EnvironmentObject var model: RenderingModel
    
    let template: Template
    @State var isOn: Bool
    
    init(template: Template, packageValues: JSON) {
        self.template = template
        var initialToggleValue = template.included
        if let value = template.shouldInclude?.shouldInclude(values: packageValues) {
            initialToggleValue = value
        }
        
        _isOn = .init(initialValue: initialToggleValue)
    }
    
    
    var body: some View {
        Toggle("", isOn: $isOn)
            .onChange(of: isOn) { value in
                model.updateInclude(template: template, value: value)
            }
            .onReceive(model.$packageInfo) { newValue in
                if let value = template.shouldInclude?.shouldInclude(values: newValue) {
                   isOn = value
                }
            }
    }
}
