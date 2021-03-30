//
//  NoteTableViewController.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 10/2/21.
//

import UIKit
import CoreData

class NoteTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //MARK: - Properties
    var dataController: DataController?
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchResultsController?.delegate = self
            executeSearch()
            tableView.reloadData()
        }
    }
    
    var notebook: NotebookMO?
    
    //MARK: - Initializers
    
    init() {
        super.init(style: .grouped)
    }
    
    public convenience init(dataController: DataController) {
        self.init()
        self.dataController = dataController
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        title = notebook?.title
        initializeFetchResultsController()
        setupNavigationItem()
        
    }
    
    func initializeFetchResultsController() {
        guard let dataController = dataController, let notebook = notebook else {return}
        let managedObjectContext = dataController.viewContext
    
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let noteTitleSortDescriptor = NSSortDescriptor(key: "createdAt",
                                                       ascending: true)
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
    
    //MARK: - Search for a note function
    func searchNotes(title: String) {
        guard let notebook = notebook else {return}
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortByTitle]
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "notebook == %@ AND title contains[cd] %@", notebook, title)
        
        guard let managedObjectContext = dataController?.viewContext else {return}
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        
    }
    
    func executeSearch() {
        if let fetchedResult = fetchResultsController {
            do {
                try fetchedResult.performFetch()
            } catch let error as NSError {
                print("Error while trying to perform search: \n\(error)\n\(String(describing: fetchResultsController))")
            }
        }
    }
    
    
    //MARK: - Navigation items setup
    func setupNavigationItem(){
        let addNoteBarButtonItem = UIBarButtonItem(title: "Add note", style: .done, target: self, action: #selector(createAndPresentPicker))
        
        navigationItem.rightBarButtonItem = addNoteBarButtonItem
        
    }
    
    @objc
    func createAndPresentPicker(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary),
           let availableTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            picker.mediaTypes = availableTypes
            
        }
        
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
               if let url = info[.imageURL] as? URL {
                // data controller para poder crear la nota
                if let notebook = self?.notebook {
                    self?.dataController?.addNote(urlImage: url, notebook: notebook)
                    
                }
                
            }
            
        }
        
    }
    
    
    //MARK: - TableView methods
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
        
        if let imagePicture = note.photograph,
           let imageData = (imagePicture.allObjects.first as? PhotographMO)?.imageData,
           let imageUI = UIImage(data: imageData) {
            
            cell.imageView?.image = imageUI
            
        }
    
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let note = self.fetchResultsController?.object(at: indexPath) as? NoteMO else {
            fatalError("no indexpath")
        }
        self.performSegue(withIdentifier: "SEGUE_TO_NOTE_DETAIL", sender: note)
    }
    
    
    //MARK: - Navigation-Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? NoteDetailViewController
        if let note = sender as? NoteMO {
            destination?.note = note
            destination?.dataController = dataController
        }
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

//MARK: - SearchBar Delegate
extension NoteTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchTextEntered = searchBar.text else {return}
        
        searchNotes(title: searchTextEntered)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.isFirstResponder { searchBar.resignFirstResponder()}
    }
    
}


