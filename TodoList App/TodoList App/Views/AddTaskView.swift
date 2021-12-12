//
//  AddTaskView.swift
//  TodoList App
//
//  Created by Mai Ra scc on 11/12/21.
//

import SwiftUI
import EventKit
import CoreData

struct AddTaskView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    
    @State var isEditing: EditMode = .inactive
    @State var txtnote: String = ""
    @State var editNote = Notes()
    @State var setReminder: Bool = false
   
    @State var selectedDate = Date()
    let eventStore : EKEventStore = EKEventStore()
    
    @Binding var taskData: Notes!
    @Binding var isEdit: Bool
    @Binding var isChanges: Bool
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .center,spacing:25) {
                
                Spacer()
                    .frame(height: 50)
                
                TextField("Enter task here..", text: $txtnote)
                    .font(.system(size: 18, weight: .regular, design: .default))
                
                Toggle("Set event", isOn: $setReminder)
                    .font(.system(size: 18, weight: .regular, design: .default))
                
                if setReminder {
                    
                    DatePicker("Date and Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .font(.system(size: 18, weight: .regular, design: .default))
                }
                
                Spacer()
                    .frame(height: 30)
                
                Button(action: {
                    
                    if txtnote != "" {
                        
                        if isEdit{
                            
                            isChanges = true
                            taskData.note = txtnote
                            
                            if setReminder {
                                taskData.reminder = selectedDate
                            }
                            self.presentationMode.wrappedValue.dismiss()
                            
                        }
                        else
                        {
                            addItem()
                        }
                    }
                }) {
                    
                    Text(!isEdit ? "Add Task" : "Edit Task")
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .padding(20)
                        .frame(maxWidth: .infinity, minHeight: 40, alignment: .center)
                    
                }
                .frame(width: 150, height: 35, alignment: .center)
                .padding(5)
                .background(Color.accentColor)
                .buttonStyle(PlainButtonStyle())
                .cornerRadius(10)
                
                Spacer()
            }
            .onAppear(perform: {
                
                if isEdit {
                   
                    txtnote = taskData.note!
                    selectedDate = taskData.reminder ?? Date()
                    if taskData.reminder != nil {
                        
                        setReminder = true
                    }
                }
            })
            .padding()
            .navigationTitle(!isEdit ? "Add Task" : "Edit Task")
        }
      
    }
    
    private func addItem() {
        
        withAnimation {
            
            if setReminder {
                
                let newItem = Notes(context: viewContext)
                newItem.note = txtnote
                newItem.reminder = selectedDate
               
                let startDate = selectedDate
                let endDate = selectedDate
                
                eventStore.requestAccess(to: .event) { (granted, error) in
                    
                    if (granted) && (error == nil) {
                        
                        let event:EKEvent = EKEvent(eventStore: self.eventStore)
                        event.title = txtnote
                        event.startDate = startDate
                        event.endDate = endDate
                        event.alarms = [EKAlarm(absoluteDate: selectedDate)]
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        do {
                            try self.eventStore.save(event, span: .thisEvent,commit: true)
                            newItem.eventId = event.eventIdentifier
                            print("event id is :",event.eventIdentifier!)
                            do
                            {
                                try viewContext.save()
                                presentationMode.wrappedValue.dismiss()
                            }
                            catch {
                               
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
                        catch
                        {
                            
                        }
                    }
                }
            }
            else
            {
                let newItem = Notes(context: viewContext)
                newItem.note = txtnote
                txtnote = ""
                do
                {
                    try viewContext.save()
                    presentationMode.wrappedValue.dismiss()
                }
                catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
            
           
        }
    }
    
    func edit() {
        
        if setReminder {
            
            editNote.objectWillChange.send()
            self.editNote.reminder = self.selectedDate
            self.editNote.note = self.txtnote
            editNote.eventId = taskData.eventId
            try? self.viewContext.save()
            
        }
        else
        {
            editNote.objectWillChange.send()
            editNote.note = txtnote
            try? self.viewContext.save()
        }
        
        
    }
}

//struct AddTaskView_Previews: PreviewProvider {
//
//    static var previews: some View {
//
//        AddTaskView()
//    }
//}
