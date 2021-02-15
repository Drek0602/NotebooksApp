//
//  PhotographMO+CoreDataClass.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 13/2/21.
//
//

import Foundation
import CoreData

@objc(PhotographMO)
public class PhotographMO: NSManagedObject {
    
    @discardableResult //
    static func createPhotograph(imageData: Data, managedObjectContext: NSManagedObjectContext) -> PhotographMO? {
        
        let picture = NSEntityDescription.insertNewObject(forEntityName: "Photograph", into: managedObjectContext) as? PhotographMO
        
        picture?.imageData = imageData
        
        return picture
    
    }
    
}
