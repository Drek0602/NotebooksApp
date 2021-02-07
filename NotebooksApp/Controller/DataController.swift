//
//  DataController.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 31/1/21.
//

import Foundation
import CoreData

class DataController: NSObject {
    
    private let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    @discardableResult 
    init(modelName: String, optionalStoreName: String?, completionHandler: (@escaping (NSPersistentContainer?) -> ())) {
        
        if let optionalStoreName = optionalStoreName {
            let managedObjectModel = Self.managedObjectModel(with: modelName)
            self.persistentContainer = NSPersistentContainer(name: optionalStoreName, managedObjectModel: managedObjectModel)
            
        } else {
            self.persistentContainer = NSPersistentContainer(name: modelName)
        }
        
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
            print("Failure saving view context")
            print("\(error.localizedDescription)")
        }
        
    }
    
    func reset () {
        persistentContainer.viewContext.reset()
    }
    
    
    //function to create the managedObjectModel
    static func managedObjectModel(with name: String) -> NSManagedObjectModel {
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
            fatalError("Error: could not find model")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error: could not initialize model from: \(modelURL)")
        }
        
        return managedObjectModel
        
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
