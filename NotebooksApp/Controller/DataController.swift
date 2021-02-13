//
//  DataController.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 31/1/21.
//

import Foundation
import CoreData
import UIKit

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
            
            super.init()
            
            persistentContainer.loadPersistentStores { (description, error) in
                if let error = error {
                    fatalError("Could not load CoreData Stack \(error.localizedDescription)")
                }
                
                completionHandler(self.persistentContainer)
                
            }
            
        } else {
            self.persistentContainer = NSPersistentContainer(name: modelName)
            
            super.init()
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.persistentContainer.loadPersistentStores { [weak self] (description, error) in
                    if let error = error {
                        fatalError("Could not load coreData: \(error)")
                    }
                    
                    DispatchQueue.main.async {
                        completionHandler(self?.persistentContainer)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func fetchNotebooks(using fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [NotebookMO]? {
        
        do{
            return try persistentContainer.viewContext.fetch(fetchRequest) as? [NotebookMO]
        } catch {
            fatalError("Failure to fetch notebooks with context: \(fetchRequest), \(error)")
        }
        
    }
    
    func fetchNotes(using fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [NoteMO]? {
        do{
            return try persistentContainer.viewContext.fetch(fetchRequest) as? [NoteMO]
        } catch {
            fatalError("Failure to fetch notes with context: \(fetchRequest) \(error)")
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
    
    func delete() {
        let persistentURL = persistentContainer.persistentStoreCoordinator.url(for: persistentContainer.persistentStoreCoordinator.persistentStores[0])
        
        do {
            
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: persistentURL, ofType: NSSQLiteStoreType, options: nil)
            
        } catch {
            fatalError("")
            
        }
    
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
    
    func loadNotesIntoViewContext() {
        let managedObjectContext = viewContext
        //crear notas
       guard let notebook = NotebookMO.createNotebook(createdAt: Date(),
                                                      title: "notebookWithNote",
                                                      in: managedObjectContext) else {return}
        
        NoteMO.createNote(managedObjectContext: managedObjectContext,
                          notebook: notebook,
                          title: "Nota 1",
                          createdAt: Date())
        NoteMO.createNote(managedObjectContext: managedObjectContext,
                          notebook: notebook,
                          title: "Nota 2",
                          createdAt: Date())
        NoteMO.createNote(managedObjectContext: managedObjectContext,
                          notebook: notebook,
                          title: "Nota 3",
                          createdAt: Date())
        
        let image = UIImage(named: "sketchbook")
        if let dataImage = image?.pngData() {
            let picture = PhotographMO.createPicture(imageData: dataImage, managedObjectContext: managedObjectContext)
            
            notebook.photograph = picture
        }
        
        
    }
    
    
    func loadNotebooksIntoViewContext() {
        let managedObjectContext = viewContext
        
        NotebookMO.createNotebook(createdAt: Date(), title: "notebook1", in: managedObjectContext)
        
        NotebookMO.createNotebook(createdAt: Date(), title: "notebook2", in: managedObjectContext)
        
        NotebookMO.createNotebook(createdAt: Date(), title: "notebook3", in: managedObjectContext)
        
    }
    
    /*func loadPicturesIntoViewContext() {
        let managedObjectContext = viewContext
        let imageData = UIImage(named: "")
        
        PhotographMO.createPicture(imageData: Data, managedObjectContext: managedObjectContext)
        
        NotebookMO.createNotebook(createdAt: Date(), title: "notebook2", in: managedObjectContext)
        
        NotebookMO.createNotebook(createdAt: Date(), title: "notebook3", in: managedObjectContext)
        
    }*/
    
    
}
