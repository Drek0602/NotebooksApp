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
    
    //MARK: - Perform loading in background 
    func performInBackground(_ closure: @escaping (NSManagedObjectContext) -> Void) {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        privateMOC.parent = viewContext
        
        privateMOC.perform {
            closure(privateMOC)
        }
    }
    
}



//MARK: - Fetch - Save - Delete - Reset
extension DataController {
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
}
    
    


//MARK: - loadInto
extension DataController {
    static func preloadData(managedObjectContext: NSManagedObjectContext) {
        let notebook = NotebookMO.createNotebook(createdAt: Date(), title: "notebook", in: managedObjectContext)
        
        let note = NoteMO.createNote(managedObjectContext: managedObjectContext, title: "note", createdAt: Date())
        
        note?.notebook = notebook
        
        do{
            try managedObjectContext.save()
        } catch {
            fatalError("Unable to save context: \(error.localizedDescription)")
        }
        
    }
    
    func loadNotesinBackgroundContext() {
        
        performInBackground { (privateManagedObjectContext) in
            let managedObjectContext = privateManagedObjectContext
            
            guard let notebook = NotebookMO.createNotebook(createdAt: Date(),
                                                           title: "notebookWithNote",
                                                           in: managedObjectContext) else {return}
            
            let image = UIImage(named: "sketchbook")
            guard let dataImage = image?.pngData(),
                let picture = PhotographMO.createPhotograph(imageData: dataImage, managedObjectContext: managedObjectContext) else {return}
            
            NoteMO.createNote(managedObjectContext: managedObjectContext,
                              notebook: notebook,
                              title: "Nota 1",
                              photograph: picture,
                              createdAt: Date())
            NoteMO.createNote(managedObjectContext: managedObjectContext,
                              notebook: notebook,
                              title: "Nota 2",
                              photograph: picture,
                              createdAt: Date())
            NoteMO.createNote(managedObjectContext: managedObjectContext,
                              notebook: notebook,
                              title: "Nota 3",
                              photograph: picture,
                              createdAt: Date())
        
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalError("unable to save from private MOC")
            }
            
            
        }
        
    }
    
    func loadNotesIntoViewContext(){
        let managedObjectContext = viewContext
        
        guard let notebook = NotebookMO.createNotebook(createdAt: Date(),
                                                       title: "notebookWithNote",
                                                       in: managedObjectContext) else {return}
        
        let image = UIImage(named: "sketchbook")
        guard let dataImage = image?.pngData(),
            let picture = PhotographMO.createPhotograph(imageData: dataImage, managedObjectContext: managedObjectContext) else {return}
        
        NoteMO.createNote(managedObjectContext: managedObjectContext,
                          notebook: notebook,
                          title: "Nota 1",
                          photograph: picture,
                          createdAt: Date())
        NoteMO.createNote(managedObjectContext: managedObjectContext,
                          notebook: notebook,
                          title: "Nota 2",
                          photograph: picture,
                          createdAt: Date())
        NoteMO.createNote(managedObjectContext: managedObjectContext,
                          notebook: notebook,
                          title: "Nota 3",
                          photograph: picture,
                          createdAt: Date())
        
        
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("")
            
        }
        
    }
    
    func loadNotebooksIntoViewContext() {
        
    let managedObjectContext = viewContext
    
    NotebookMO.createNotebook(createdAt: Date(), title: "notebook1", in: managedObjectContext)
    
    NotebookMO.createNotebook(createdAt: Date(), title: "notebook2", in: managedObjectContext)
    
    NotebookMO.createNotebook(createdAt: Date(), title: "notebook3", in: managedObjectContext)
    
}
    
}

//MARK: - addNotebook, addNote, addPhotograph
extension DataController {
    func addNotebook() {
        performInBackground({ (managedObjectContext) in
            NotebookMO.createNotebook(createdAt: Date(), title: "Notebook", in: managedObjectContext)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        })
    }
    
    func addNote(urlImage: URL, notebook: NotebookMO) {
    
    performInBackground { (managedObjectContext) in
        
        let notebookMOObjectID = notebook.objectID
        let copyNotebook = managedObjectContext.object(with: notebookMOObjectID) as! NotebookMO
        
        //downsampling of thumbnail
        guard let imageThumbnail = DownSampler.downsample(imageAt: urlImage),
                let imageThumbnailData = imageThumbnail.pngData()  else {
            return
        }
        
        //create photograph
        guard let photographMO = PhotographMO.createPhotograph(imageData: imageThumbnailData, managedObjectContext: managedObjectContext) else {return}
        
        //create Note
        NoteMO.createNote(managedObjectContext: managedObjectContext, notebook: copyNotebook, title: "note title", photograph: photographMO, createdAt: Date())
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("unable to create note with thumbnail image in background")
        }
        
    }
}
    
    func addPhotograph(with selectedImage: UIImage, and urlImage: URL?, in note: NoteMO) {
        performInBackground({ [weak note] (managedObjectContext) in
            guard let note = note else {
                return
            }
            
            func saveImage(image: UIImage) {
                guard let imageData = image.pngData(),
                      let photograph = PhotographMO.createPhotograph(imageData: imageData, managedObjectContext: managedObjectContext) else {
                    fatalError("couldn't create photograh")
                }
                
                NoteMO.addPhoto(note: note, picture: photograph, managedObjectContext: managedObjectContext)
            }
            
            if let urlImage = urlImage,
               let thumbnailImage = DownSampler.downsample(imageAt: urlImage) {
                saveImage(image: thumbnailImage)
            } else {
                saveImage(image: selectedImage)
            }
        })
    }
}


        


    
    


