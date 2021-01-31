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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
            
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInit_DataController_Initializes()  {
        
        DataController(modelName: "NotebooksModel") { _ in
            XCTAssert(true)
            
        }
        
    }
    
    func  testInit_Notebook() {
        
        DataController(modelName: "NotebooksModel") { (persistentContainer) in
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
        
        /*DataController(modelName: "NotebooksModel") {
            let notebook = NotebookMO.createNotebook(createdAt: Date(), title: "notebook1", in: <#T##NSManagedObjectContext#>)
        }*/
    }
    

}
