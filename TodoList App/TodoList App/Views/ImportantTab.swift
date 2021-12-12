//
//  ImportantTab.swift
//  TodoList App
//
//  Created by Mai Ra on 11/12/21.
//

import SwiftUI

struct ImportantTab: View {
    
    @Environment(\.managedObjectContext) var viewContext
   
    @FetchRequest(entity: Notes.entity(),sortDescriptors: [],predicate: NSPredicate(format: "(is_important == %i)", true))
    
    var arrImportant: FetchedResults<Notes>
    var body: some View {
        
        NavigationView{
            
            VStack(alignment: .leading){
                
                Form {                    
                    List {
                        
                        ForEach(arrImportant) { note in
                           
                            HStack {
                                
                                Text(note.note!)
                                Spacer()
                                Button(action: {
                                    
                                    updateImpoertant(note: note)
                                    
                                }) {
                                    Image(note.is_important ? "ic_checked" : "ic_unchecked")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                }
                                .buttonStyle(PlainButtonStyle())
                                Spacer()
                                    .frame(width: 5)
                                
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Important Notes"))
            .onAppear(){
                
                print(arrImportant)
            }
        }
    }
    func updateImpoertant(note: Notes) {
        
        let newStatus = note.is_important == false ? true : false
        
        viewContext.performAndWait {
            note.is_important = newStatus
            try? self.viewContext.save()
        }
    }
}

struct ImportantTab_Previews: PreviewProvider {
    static var previews: some View {
        ImportantTab()
    }
}
