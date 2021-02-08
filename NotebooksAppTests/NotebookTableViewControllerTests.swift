//
//  NotebookTableControllerTests.swift
//  NotebooksAppTests
//
//  Created by Tim Acosta on 7/2/21.
//

import XCTest
import CoreData
@testable import NotebooksApp

class NotebookTableViewControllerTests: XCTestCase {
    
    let modelName = "NotebooksModel"
    let optionalStoreName = "NotebooksModelTest"

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        try super.tearDownWithError()
        
        DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistentContainer) in
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
    
    func testFetchResultsController_FetchesNotebooks() {
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistentContainer) in }
        
        dataController.loadNotebooksIntoViewContext()
        dataController.save()
        dataController.reset()
        
        let notebookViewController = NotebookTableViewController(dataController: dataController)
        
        notebookViewController.loadViewIfNeeded()
       let foundNotebooks =  notebookViewController.fetchResultsController?.fetchedObjects?.count
        
        XCTAssertEqual(foundNotebooks, 3)
        
    }
    
}
