//
//  SwiftUIView.swift
//  
//
//  Created by Qiwei Li on 1/26/23.
//

import SwiftUI

struct FileListView: View {
    let templates: [Template]
    
    var body: some View {
        Table(templates) {
            TableColumn("File Name", value: \.outputFilePath)
        }
    }
}
