//
//  DataController.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 31/1/21.
//

import Foundation
import CoreData

class DataController: NSObject {
    
    var persistentContainer: NSPersistentContainer
    
    @discardableResult 
    init(modelName: String, completionHandler: (@escaping (NSPersistentContainer?) -> ())) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
        
        super.init()
        
        
        persistentContainer.loadPersistentStores { [weak self] (description, error) in
            if let error = error {
                fatalError("Could not load coreData: \(error)")
            }
            
            completionHandler(self?.persistentContainer)
            
        }
        
    }
    
    func fetchNotebooks(using fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [NotebookMO]? {
        
        do{
            return try persistentContainer.viewContext.fetch(fetchRequest) as? [NotebookMO]
        } catch {
            fatalError("Failure to fetch notebooks with context: \(fetchRequest), \(error)")
        }
        
    }
    
    func save() {
        do {
            return try persistentContainer.viewContext.save()
        } catch {
            fatalError("Failure saving view context")
            print("\(error.localizedDescription)")
        }
        
        
    }
       
    
}

extension DataController {
    func loadNotebooksIntoViewContext() {
        let managedObjectContext = persistentContainer.viewContext
        
        NotebookMO.createNotebook(createdAt: Date(), title: "notebook1", in: managedObjectContext)
        
        NotebookMO.createNotebook(createdAt: Date(), title: "notebook2", in: managedObjectContext)
        
        NotebookMO.createNotebook(createdAt: Date(), title: "notebook3", in: managedObjectContext)
        
    }
    
}
