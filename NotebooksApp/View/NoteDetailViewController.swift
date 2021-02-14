//
//  NoteDetailViewController.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 13/2/21.
//

import Foundation
import UIKit
import CoreData

class NoteDetailViewController: UIViewController, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var note: NoteMO?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleUITextField: UITextField!
    @IBOutlet weak var contentUITextView: UITextView!
    
    
    //private var blockOperation = BlockOperation()
    
    //MARK: - Properties
    var dataController: DataController?
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>
    
    //TODO
    func initializeFetchResultsController() {
        
        guard let dataController = dataController, let note = note else {return}
        
        let managedObjectContext = dataController.viewContext
        
        //create fetchRequest
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photograph")
        
        let photographDateSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        
        request.predicate = NSPredicate(format: "note == %@", note)
        request.sortDescriptors = [photographDateSortDescriptor]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultsController.delegate = self
        
        do{
            try fetchResultsController.performFetch()
        } catch {
            fatalError("unable to fetch note details")
        }
        
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    
    public convenience init(dataController: DataController) {
        self.init()
        self.dataController = dataController
        
        self.titleUITextField = UITextField()
        self.contentUITextView = UITextView()
        
        collectionView.dataSource = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        titleUITextField.text = note?.title
        contentUITextView.text =  note?.contents
        
    }
    
    //MARK: - Picker functions
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
    
    //TODO
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {}
    
    //TODO
    func addNewPicNoteDetail(selectedImage: UIImage, url: URL?) {}
    

    //MARK: - UICollection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Change this one..
        return fetchResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photographCell", for: indexPath) as? PictureCollectionViewCell,
              let picture = fetchResultsController.object(at: indexPath) as? PhotographMO,
              let imageData = picture.imageData else {
            return UICollectionViewCell()
        }
        
        cell.imageDetailView.image = UIImage(data: imageData)
        
        return cell
        
    }
    
    
}
 
extension NoteDetailViewController: NSFetchedResultsControllerDelegate {
    
}
