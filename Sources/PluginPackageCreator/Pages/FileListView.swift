//
//  SwiftUIView.swift
//
//
//  Created by Qiwei Li on 1/26/23.
//

import SwiftUI

struct FileListView: View {
    @EnvironmentObject var model: TemplateRenderingModel

    var body: some View {
        Table(model.package?.templates ?? []) {
            TableColumn("Includes") { template in
                TemplateIncludeToggle(template: template, includedTemplates: model.includedTemplate)
            }
            TableColumn("Title", value: \.name)
            TableColumn("Description", value: \.description)
            TableColumn("Output Path") { template in
                let text = model.renderOutputPath(template: template)
                Text(text ?? "Error")
                    .underline()
            }
            TableColumn("Downloaded") { template in
                DownloadedIndicator(downloaded: model.downloadedTemplates, template: template)
            }
        }
    }
}
