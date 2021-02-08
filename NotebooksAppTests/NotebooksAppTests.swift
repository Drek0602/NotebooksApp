//
//  NotebooksAppTests.swift
//  NotebooksAppTests
//
//  Created by Tim Acosta on 31/1/21.
//

import XCTest
import CoreData
@testable import NotebooksApp

class NotebooksAppTests: XCTestCase {
    
    private let modelName = "NotebooksModel"
    private let optionalStore = "NotebooksTest"

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
            
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        try super.tearDownWithError()
        
        DataController(modelName: modelName, optionalStoreName: optionalStore) { (persistentContainer) in
            guard let persistentContainer = persistentContainer else {
                fatalError("could not delete database")
            }
            
            let persistentURL = persistentContainer.persistentStoreCoordinator.url(for: persistentContainer.persistentStoreCoordinator.persistentStores[0])
            
            do {
                
                try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: persistentURL, ofType: NSSQLiteStoreType, options: nil)
                
            } catch {
                fatalError("")
                
            }
        }
        
    }
    
    func testInit_DataController_Initializes()  {
        
        DataController(modelName: modelName, optionalStoreName: optionalStore) { _ in
            XCTAssert(true)
            
        }
        
    }
    
    func  testInit_Notebook() {
        
        DataController(modelName: modelName, optionalStoreName: optionalStore) { (persistentContainer) in
            guard let persistentContainer = persistentContainer else {
                XCTFail()
                return
            }
            
            let managedObjectContext = persistentContainer.viewContext
            
            let notebook1 = NotebookMO.createNotebook(createdAt: Date(),
                                                     title: "notebook1",
                                                     in: managedObjectContext)
            
            XCTAssertNotNil(notebook1)
            
        }
        
    }
    
    func testFetch_DataController_FetchesANotebook() {
        
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStore) { (persistentContainer) in
            guard let managedObjectContext = persistentContainer?.viewContext else {
                XCTFail()
                return
            }
            
            self.insertNotebooksInto(managedObjectContext: managedObjectContext)
            
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        let notebooks = dataController.fetchNotebooks(using: fetchRequest)
        
        XCTAssertEqual(notebooks?.count, 3)
    }
    
    func testFilter_DataController_FilterNotebooks() {
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStore) { (persistentContainer) in
            guard let managedObjectContext = persistentContainer?.viewContext else {
                XCTFail()
                return
            }
            
            self.insertNotebooksInto(managedObjectContext: managedObjectContext)
            
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        
        fetchRequest.predicate = NSPredicate(format: "title == %@", "notebook1")
        
        let notebooks = dataController.fetchNotebooks(using: fetchRequest)
        
        XCTAssertEqual(notebooks?.count, 1)
        
    }
    
    func testSaves_DataController_SaveInPersistentStore() {
        
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStore) { (persistentContainer) in
            guard let managedObjectContext = persistentContainer?.viewContext else {
                XCTFail()
                return
                
            }
            
        }
        
        //cargar datos
        dataController.loadNotebooksIntoViewContext()
        //salvar datos del managedobjectContext
        dataController.save()
        
        //clean up / reset al managedobjectContext para borrar los datos de memoria
        dataController.reset()
        
        //cargar
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        let notebook = dataController.fetchNotebooks(using: fetchRequest)
        
        XCTAssertEqual(notebook?.count, 3)
        
    }
    
    func testDelete_DataController_DeleDataInPersistentStore() {
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStore) { (persistentContainer) in
            guard let managedObjectContext = persistentContainer?.viewContext else {
                XCTFail()
                return
                
            }
            
        }
        
        //cargar datos
        dataController.loadNotebooksIntoViewContext()
        //salvar datos del managedobjectContext
        dataController.save()
        
        //clean up / reset al managedobjectContext para borrar los datos de memoria
        dataController.reset()
        
        //delete data
        dataController.delete()
        
        //cargar
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        let notebook = dataController.fetchNotebooks(using: fetchRequest)
        
        XCTAssertEqual(notebook?.count, 0)
    }
    
    
    //MARK: - Helper Methods
    func insertNotebooksInto(managedObjectContext: NSManagedObjectContext) {
        NotebookMO.createNotebook(createdAt: Date(), title: "notebook1", in: managedObjectContext)
        
        NotebookMO.createNotebook(createdAt: Date(), title: "notebook2", in: managedObjectContext)
        
        NotebookMO.createNotebook(createdAt: Date(), title: "notebook3", in: managedObjectContext)
    }
    
}
