//
//  SwiftUIView.swift
//  
//
//  Created by Qiwei Li on 1/26/23.
//

import SwiftUI

struct FileListView: View {
    @EnvironmentObject var model: RenderingModel
    
    let templates: [Template]
    let downloaded: [Template]
    
    var body: some View {
        Table(templates) {
            TableColumn("Includes") { template in
                TemplateIncludeToggle(template: template)
            }
            TableColumn("Title", value: \.name)
            TableColumn("Description", value: \.description)
            TableColumn("Output Path"){ template in
                let text = model.renderOutputPath(template: template)
                Text(text ?? "Error")
                    .underline()
            }
            TableColumn("Downloaded") { template in
                DownloadedIndicator(downloaded: downloaded, template: template)
            }
        }
    }
}
