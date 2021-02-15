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
    
    //init de cualquier clas NSObject, y deinit
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        print("notebook created")
       
        
    }
    
    public override func didTurnIntoFault() {
        super.didTurnIntoFault()
        
        print("fault created")
    }
    
    static var format: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    static func textFrom(date: Date) -> String {
        return format.string(from: date)
    }
    
    //Binary Large Data Objects, registro dentro de NSPErsistentStore SQLLite > 1MB
    //CLOB = character large object de 128 bytes 1 millon de registro, es considerado un BLOB.
    
    @discardableResult
    static func createNotebook(createdAt: Date,
                               title: String,
        in managedObjectContext: NSManagedObjectContext) -> NotebookMO? {
        let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook",
                                                           into: managedObjectContext) as? NotebookMO
        
        notebook?.createdAt = createdAt
        notebook?.title = title
        notebook?.image = UIImage(named: "sketchbook")?.pngData()
        
        return notebook
    }

}
