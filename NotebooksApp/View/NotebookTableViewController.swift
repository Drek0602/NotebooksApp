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
        super.init(coder: coder)
    }
    
    func initializeFetchResultsController() {
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
        
        self.fetchResultsController?.delegate = self
        
    }
    
    
    //MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeFetchResultsController()
        
        let loadDataBarButton = UIBarButtonItem(title: "Load", style: .done, target: self, action: #selector(loadData))
        
        let deleteDataBarButton = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteData))
        
        navigationItem.leftBarButtonItems = [loadDataBarButton, deleteDataBarButton]
        
    }
    
    @objc
    func loadData() {
        dataController?.performInBackground({ (managedObjectContext) in
            DataController.preloadData(managedObjectContext: managedObjectContext)
        })
    }
    
    @objc
    func deleteData() {
        dataController?.save()
        dataController?.delete()
        dataController?.reset()
        initializeFetchResultsController()
        tableView.reloadData()
    }
    
    //MARK: - TableView Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultsController?.sections?.count ?? 0
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetchResultsController = fetchResultsController {
            return fetchResultsController.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notebookCell", for: indexPath)
        
        guard let notebook = fetchResultsController?.object(at: indexPath) as? NotebookMO else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        cell.textLabel?.text = notebook.title
        if let createdAt = notebook.createdAt {
            cell.detailTextLabel?.text = HelperDateFormatter.textFrom(date: createdAt)
        }
        
        cell.imageView?.image = UIImage(data: notebook.image ?? Data())
        
        return cell
        
    }
    
    //MARK: - Navigation - prepareforSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueIdentifier = segue.identifier,
           segueIdentifier == "SEGUE_TO_NOTE" {
            //encontrar o castear el notebooktableviewcontroller
            //tenemos que encontrar el notebook que elegimos y setear el notebook
            // luego setear el datacontroller
            let destination = segue.destination as? NoteTableViewController
            let indexPathSelected = tableView.indexPathForSelectedRow!
            let selectedNotebook = fetchResultsController?.object(at: indexPathSelected) as? NotebookMO
            
            destination?.notebook = selectedNotebook
            destination?.dataController = dataController
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SEGUE_TO_NOTE", sender: nil)
    }

    
}



//MARK: - NSFetchedResultsController
extension NotebookTableViewController: NSFetchedResultsControllerDelegate {
    // if view context will change
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    //did change a section
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            case.move, .update:
            break
            @unknown default: fatalError()
        }
        
    }
    //did change an object
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            @unknown default:
                fatalError()
        }
    }
    //did change content
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
