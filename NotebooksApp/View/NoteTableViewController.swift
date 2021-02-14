//
//  NoteTableViewController.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 10/2/21.
//

import UIKit
import CoreData

class NoteTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var dataController: DataController?
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    var notebook: NotebookMO?
    
    public convenience init(dataController: DataController) {
        self.init()
        self.dataController = dataController
    }
    
    func initializeFetchResultsController() {
        guard let dataController = dataController, let notebook = notebook else {return}
        
        let managedObjectContext = dataController.viewContext
        
        //create fetchRequest
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteTitleSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        
        request.predicate = NSPredicate(format: "notebook == %@", notebook)
        request.sortDescriptors = [noteTitleSortDescriptor]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        
        fetchResultsController?.delegate = self
        
        do{
            try fetchResultsController?.performFetch()
        } catch {
            fatalError("unable to fetch notes from notebook: \(error.localizedDescription)")
        }
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchResultsController()
        
        setupNavigationItem()
        
    }
    
    func setupNavigationItem(){
        let addNoteBarButtonItem = UIBarButtonItem(title: "Add note", style: .done, target: self, action: #selector(createAndPresentPicker))
        
        navigationItem.rightBarButtonItem = addNoteBarButtonItem
        
    }
    
    @objc
    func createAndPresentPicker(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        
        guard let note = fetchResultsController?.object(at: indexPath) as? NoteMO else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        cell.textLabel?.text = note.title
        if let createdAt = note.createdAt {
            cell.detailTextLabel?.text = HelperDateFormatter.textFrom(date: createdAt)
        }
    
        return cell
        
    }
    

}

// MARK:- NSFetchResultsControllerDelegate.
extension NoteTableViewController: NSFetchedResultsControllerDelegate {
    
    // will change
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    // did change a section.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move, .update:
            break
        @unknown default: fatalError()
        }
    }
    
    // did change an object.
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
    
    // did change content.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}


