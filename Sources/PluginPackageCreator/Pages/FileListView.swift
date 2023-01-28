//
//  SwiftUIView.swift
//  
//
//  Created by Qiwei Li on 1/26/23.
//

import SwiftUI
import CodeEditTextView

struct FileListView: View {
    @EnvironmentObject var model: RenderingModel
    
    let templates: [Template]
    let downloaded: [Template]
    
    var body: some View {
        Table(templates) {
            TableColumn("Title", value: \.name)
            TableColumn("Description", value: \.description)
            TableColumn("Output Path") { template in
                PopoverView {
                    Text(model.renderOutputPath(template: template) ?? "Error in generating output path")
                        .underline()
                } popover: {
                    CodeView(template: template)
                }

                
            }
            TableColumn("Downloaded") { template in
                DownloadedIndicator(downloaded: downloaded, template: template)
            }
        }
    }
}
