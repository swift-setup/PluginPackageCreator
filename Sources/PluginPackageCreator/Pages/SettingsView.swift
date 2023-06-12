//
//  SwiftUIView.swift
//  
//
//  Created by 林彦君 on 2/6/23.
//

import SwiftUI
import PluginInterface

struct SettingsView: View {
    let store: StoreUtilsProtocol
    let plugin: any PluginInterfaceProtocol
    
    //1. Create a textfield
    
    @State var info: String = ""
    @State var saved: Bool = false
    //2. Button
    
    //3. After clicking the button, the data from textfield should be stored in your store
    
    //4. Should initialize the textfield's default value using the value stored in your store
    
    var body: some View {
        Form {
            Section("Index URL") {
                TextField("Remote index url", text: $info)
                Text("Remenber to refresh the repository!")
                    .foregroundColor(.red)
            }
            
            HStack {
                Button {
                    save()
                } label: {
                    if saved {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .frame(width: 50.0, height: 20.0)
                        
                    } else {
                        Text("Save")
                            .frame(width: 50.0, height: 20.0)
                    }
                }
            }

        }
        .onAppear{
            info = store.get(forKey: "repo", from: plugin) ?? ""
        }
    }
    
    
    func save() {
        store.set(info, forKey: "repo", from: plugin)
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            saved = false
        }
    }
    
    
}
