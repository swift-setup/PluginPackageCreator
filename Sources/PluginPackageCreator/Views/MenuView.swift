//
//  MenuView.swift
//
//
//  Created by Qiwei Li on 6/5/23.
//

import SwiftUI

struct MenuItemView: View {
    let item: PackageGroup
    @EnvironmentObject var model: TemplateRenderingModel

    var body: some View {
        Menu(item.name) {
            if let children = item.children {
                ForEach(children, id: \.name) { child in
                    MenuItemView(item: child)
                }
            }

            if let menus = item.menus {
                ForEach(menus, id: \.title) { repo in
                    Button(repo.title) {
                        model.selectedRepo = repo
                    }
                    .tag(repo)
                }
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MenuItemView(item: .init(name: "Hello"))
    }
}
