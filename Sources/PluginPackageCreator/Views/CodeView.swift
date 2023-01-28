//
//  SwiftUIView.swift
//  
//
//  Created by Qiwei Li on 1/28/23.
//

import SwiftUI
import CodeEditTextView

struct CodeView: View {
    let template: Template
    @EnvironmentObject var model: RenderingModel
    @State var isLoading = false
    @State var code: String = ""
    @State var theme = EditorTheme(text: .init(hex: "#D9D9D9"), insertionPoint: .init(hex: "#D9D9D9"), invisibles: .init(hex: "#424D5B"), background: .init(hex: "#1f2024").withAlphaComponent(0), lineHighlight: .init(hex: "#23252B"), selection: .init(hex: "#D9D9D9"), keywords: .white, commands: .white, types: .systemPink, attributes: .white, variables: .systemIndigo, values: .systemYellow, numbers: .init(hex: "#D0BF69"), strings: .init(hex: "#FC6A5D"), characters: .init(hex: "#D0BF69"), comments: .init(hex: "#73A74E"))
    @State var tabWidth = 4
    @State var lineHeight = 1.2
    @State var font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                CodeEditTextView($code, language: template.language, theme: $theme, font: $font, tabWidth: $tabWidth, lineHeight: $lineHeight, wrapLines: .constant(true))
            }
        }
        .frame(width: 500, height: 500)
        .task {
            isLoading = true
            do {
                code = try await model.render(template: template)
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
}
