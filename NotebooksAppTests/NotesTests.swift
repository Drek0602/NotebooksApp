//
//  NotesTests.swift
//  NotebooksAppTests
//
//  Created by Tim Acosta on 9/2/21.
//

import XCTest
import CoreData
@testable import NotebooksApp

class NotesTests: XCTestCase {
    
    private let modelName = "NotebooksModel"
    private let optionalStore = "NotebooksTest"

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        try super.tearDownWithError()
        
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStore) { (_) in }
        
        dataController.delete()
        
    }
    
    func testCreatedAndSearchNote() {
        
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStore) { (_) in }
        
        //insert notes
        dataController.loadNotesIntoViewContext()
        
        //save notes of managedObjectContext
        dataController.save()
        
        //reset
        dataController.reset()
        
        //search notes
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
       let notes = dataController.fetchNotes(using: fetchRequest)
        
        XCTAssertEqual(notes?.count, 3)
        
    }
    
    
    func testNoteViewController() {
        
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStore) { (_) in }
        
        let viewController = UIViewController()
        //let
        
        
        
    }
    
    

}
