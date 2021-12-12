//
//  TabMenu.swift
//  TodoList App
//
//  Created by Mai Ra on 11/12/21.
//

import SwiftUI

struct TabMenu: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                   
                    Text("All")
                    Image(systemName: "archivebox.fill")
                }
            ImportantTab()
                .tabItem {
                   
                    Text("Important")
                    Image(uiImage: UIImage(named: "ic_important")!)
                }
        }

    }
}

struct TabMenu_Previews: PreviewProvider {
    static var previews: some View {
        TabMenu()
    }
}
