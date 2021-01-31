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
    
    @discardableResult 
    init(modelName: String, completionHandler: (@escaping (NSPersistentContainer?) -> ())) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
        
        super.init()
        
        
        persistentContainer.loadPersistentStores { [weak self] (description, error) in
            if let error = error {
                fatalError("Could not load coreData: \(error)")
            }
            
            completionHandler(self?.persistentContainer)
            
        }
        
    }
    
}
