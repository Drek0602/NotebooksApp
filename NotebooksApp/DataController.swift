//
//  DataController.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 31/1/21.
//

import Foundation
import CoreData

class DataController: NSObject {
    
    
    var persistentContainer: NSPersistentContainer
    
    init(modelName: String, completionHandler: (@escaping () -> ())) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
        
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Could not load coreData: \(error)")
            }
            
            completionHandler()
            
        }
        
    }
    
}
