//
//  NoteTableViewController.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 10/2/21.
//

import UIKit
import CoreData

class NoteTableViewController: UITableViewController {
    
    var dataController: DataController?
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    
    
    public convenience init(dataController: DataController) {
        self.init()
        self.dataController = dataController
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let dataController = dataController else {return}
        
        let managedObjectContext = dataController.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteTitleSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        
        request.sortDescriptors = [noteTitleSortDescriptor]
        
        self.fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: <#T##NSManagedObjectContext#>, sectionNameKeyPath: <#T##String?#>, cacheName: <#T##String?#>)
        
    }

}
