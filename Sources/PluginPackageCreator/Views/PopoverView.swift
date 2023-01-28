//
//  PopoverView.swift
//  SwiftSetup
//
//  Created by Qiwei Li on 1/23/23.
//

import SwiftUI

struct PopoverView<Content: View, Popover: View>: View {
    @ViewBuilder var content: Content
    @ViewBuilder var popover: Popover
    
    @State private var showPopup = false
    @State private var hover: Bool = false
    
    var body: some View {
        content
            .padding()
            .popover(isPresented: $showPopup, content: {
                popover
                    .padding()
            })
            .onTapGesture {
                showPopup = true
            }
            .onHover { isHovered in
                self.hover = isHovered
                DispatchQueue.main.async { //<-- Here
                    if (self.hover) {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
    }
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView {
            Text("Text")
                .padding()
        } popover: {
            Text("Popover")
        }
        
    }
}
