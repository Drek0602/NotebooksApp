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
        
        let notebook = NotebookMO.createNotebook(createdAt: Date(), title: "notebook1", in: dataController.viewContext)
        
        let note = NoteMO.createNote(managedObjectContext: dataController.viewContext, notebook: notebook!, title: "note1", createdAt: Date())
        
        let noteViewController = NoteTableViewController(dataController: dataController)
        
        noteViewController.notebook = notebook
        
        //carga la vista si es necesaria..
        noteViewController.loadViewIfNeeded()
        
        let notes = noteViewController.fetchResultsController?.fetchedObjects as? [NoteMO]
        
        guard let firstFound = notes?.first else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(notes?.count, 1)
        XCTAssertEqual(note, firstFound)
        
    }
    
    

}
