//
//  SwiftUIView.swift
//
//
//  Created by Qiwei Li on 1/25/23.
//

import SwiftUI

struct DownloadedIndicator: View {
    let downloaded: [Template]
    let template: Template
    
    var body: some View {
        if let _ = downloaded.first(where: { f in
            f == template
        }) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color.green)
        } else {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Color.red)
        }
    }
}

struct DownloadedIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DownloadedIndicator(
            downloaded: [Template(name: "a", description: "b", outputFilePath: "c", shouldInclude: nil)], template: Template(name: "a", description: "b", outputFilePath: "c", shouldInclude: nil)
        )
        
        DownloadedIndicator(
            downloaded: [Template(name: "a", description: "b", outputFilePath: "c", shouldInclude: nil)], template: Template(name: "c", description: "b", outputFilePath: "c", shouldInclude: nil)
        )
    }
}
