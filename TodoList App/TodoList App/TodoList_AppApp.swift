//
//  TodoList_AppApp.swift
//  TodoList App
//
//  Created by Mai Ra on 11/12/21.
//

import SwiftUI

@main
struct TodoList_AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabMenu()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
