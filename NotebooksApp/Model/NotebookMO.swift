//
//  NotebookMO.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 31/1/21.
//

import UIKit
import Foundation
import CoreData

public class NotebookMO: NSManagedObject {
    
    static var format: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    static func textFrom(date: Date) -> String {
        return format.string(from: date)
    }
    
    @discardableResult
    static func createNotebook(createdAt: Date,
                               title: String,
        in managedObjectContext: NSManagedObjectContext) -> NotebookMO? {
        let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: managedObjectContext) as? NotebookMO
        
        notebook?.createdAt = createdAt
        notebook?.title = title
        //notebook.image = UIImage(named: "notebook")?.pngData()
        
        
        return notebook
    }

}
