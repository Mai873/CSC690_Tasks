//
//  ContentView.swift
//  TodoList App
//
//  Created by Mai Ra on 11/12/21.
//

import SwiftUI
import CoreData
import EventKit
import EventKitUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Notes.entity(), sortDescriptors: []) var arrNotes: FetchedResults<Notes>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Item>
    
    @State var isEditing: EditMode = .inactive
    let eventStore : EKEventStore = EKEventStore()
    
    @State var isOpenAddTaskView = false
    @State var taskData: Notes!
    @State var isEdit: Bool = false
    @State var isChanges: Bool = false
    
    @State var oldData: Notes!
    
    var body: some View {
        
        NavigationView {
            
            VStack{
                
                List {
                    ForEach(arrNotes) { item in
                        
                        HStack {
                            
                            Text(item.note!)
                            
                            Spacer()
                            
                            Button(action: {
                                
                                updateImpoertant(note: item)
                                
                            }) {
                                Image(item.is_important ? "ic_checked" : "ic_unchecked")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                                .frame(width: 5)
                            
                            Button(action: {
                               
                                taskData = item
                                oldData = taskData
                                isEdit = true
                                isOpenAddTaskView = true
                                
                            }) {
                                Image("ic_edit")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                                .frame(width: 5)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .environment(\.editMode, .constant(isEditing))
            }
            .onAppear(perform: {
                print("arrNotes:",arrNotes)
            })
            .sheet(isPresented: $isOpenAddTaskView, onDismiss: {
             
                print("taskdata:",taskData)
                if isEdit  && isChanges {
                    
                    edit(task: taskData)
                }
                
            }, content: {
               
                AddTaskView(taskData: $taskData,isEdit: $isEdit, isChanges: $isChanges)
            })
            .navigationTitle("Todo List")
            .navigationBarItems( trailing:
                                    
                                    HStack {
                Button(action: {
                    
                    isEdit = false
                    self.isOpenAddTaskView = true
                    
                }, label: {
                    Image(systemName: "plus")
                        .font(.system(size: 23))
                        .foregroundColor(.accentColor)
                    
                })
            })
        }
    }
    
    func updateImpoertant(note: Notes) {
        
        let newStatus = note.is_important == false ? true : false
        
        viewContext.performAndWait {
            note.is_important = newStatus
            try? self.viewContext.save()
        }
    }
    
    func edit(task:Notes) {
        
        isEdit = false
        
        viewContext.performAndWait {
            
            if task.reminder != nil  {
                
                taskData.reminder = task.reminder
                taskData.note = task.note
                
                eventStore.requestAccess(to: .event) { (granted, error) in
                    
                    if (granted) && (error == nil) {
                        
                        if task.eventId == nil {
                            
                            let event:EKEvent = EKEvent(eventStore: self.eventStore)
                            event.title = task.note
                            event.startDate = task.reminder
                            event.endDate = task.reminder
                            event.alarms = [EKAlarm(absoluteDate: task.reminder!)]
                            event.calendar = eventStore.defaultCalendarForNewEvents
                            
                            do {
                                
                                try self.eventStore.save(event, span: .thisEvent,commit: true)
                                print("event id is :",event.eventIdentifier!)
                                taskData.eventId = event.eventIdentifier!
                                try? self.viewContext.save()
                            }catch {
                                
                            }
                        }
                        else
                        {
                            let event = self.eventStore.event(withIdentifier: taskData.eventId!)!
                            event.title = task.note
                            event.startDate = task.reminder
                            event.endDate = task.reminder
                            event.alarms = [EKAlarm(absoluteDate: task.reminder!)]
                            event.calendar = eventStore.defaultCalendarForNewEvents
                           
                            do {
                                
                                try eventStore.save(event, span: .thisEvent,commit: true)
                                print("event id is :",event.eventIdentifier!)
                                taskData.eventId = event.eventIdentifier!
                                try? self.viewContext.save()
                            }
                            catch {
                                
                            }
                        }
                    }
                }
            }
            else
            {
                taskData.note = task.note
                try? self.viewContext.save()
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        
        offsets.forEach ({ index in
            
            let data = arrNotes[index]
            print("deletedData:-",data)
            if data.eventId != nil {
                DeleteEvent(task: data)
            }
        })
        
        withAnimation {
            
            offsets.map { arrNotes[$0] }.forEach(viewContext.delete)
           
            do {
               
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    
    func DeleteEvent(task:Notes){
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                
                print("granted \(granted)")
                print("deletedtaskData:-",task)
                let eventToRemove = self.eventStore.event(withIdentifier: task.eventId!)
                
                if eventToRemove != nil {
                    
                    do {
                        print("Removed")
                        try self.eventStore.remove(eventToRemove!, span: .thisEvent, commit: true)
                    }
                    catch
                    {
                        // Display error to user
                        print("error to delete")
                    }
                }
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
