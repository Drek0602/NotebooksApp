//
//  NoteMO+CoreDataClass.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 9/2/21.
//
//

import Foundation
import CoreData

@objc(NoteMO)
public class NoteMO: NSManagedObject {
    
    @discardableResult
    static func createNote(managedObjectContext: NSManagedObjectContext, notebook: NotebookMO, title: String, photograph: PhotographMO,createdAt: Date) -> NoteMO? {
        
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: managedObjectContext) as? NoteMO
        
        note?.title = title
        note?.contents = "new note"
        note?.createdAt = createdAt
        note?.notebook = notebook
        note?.addToPhotograph(photograph)
        
        return note
        
    }
    
    static func addPhoto(note: NoteMO, picture: PhotographMO, managedObjectContext: NSManagedObjectContext) {
        let noteID = note.objectID
        let copyNote = managedObjectContext.object(with: noteID) as? NoteMO
        
        copyNote?.addToPhotograph(picture)
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("unable to create note with picture")
        }
        
    }
    

}
