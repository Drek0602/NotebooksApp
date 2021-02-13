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
    
    var notebook: NotebookMO?
    
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
        
        guard let dataController = dataController, let notebook = notebook else {return}
        
        let managedObjectContext = dataController.viewContext
        
        //create fetchRequest
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteTitleSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        
        request.predicate = NSPredicate(format: "notebook == %@", notebook)
        request.sortDescriptors = [noteTitleSortDescriptor]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do{
            try fetchResultsController?.performFetch()
        } catch {
            fatalError("unable to fetch notes from notebook: \(error.localizedDescription)")
        }
       
        
    }

}
