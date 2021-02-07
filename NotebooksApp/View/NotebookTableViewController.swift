//
//  NotebookTableViewController.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 7/2/21.
//

import UIKit
import CoreData

class NotebookTableViewController: UITableViewController {
    
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
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataController = DataController(modelName: "NotebooksModel", optionalStoreName: nil, completionHandler: { _ in })
        
        guard let dataController = dataController else {return}
        
        let managedObjectContext = dataController.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        let notebookTitleSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        request.sortDescriptors = [notebookTitleSortDescriptor]
        
        self.fetchResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        do {
            try self.fetchResultsController?.performFetch()
        } catch {
            print("Error while trying to perform a notebook fetch")
        }
        
        
    }

    
}
