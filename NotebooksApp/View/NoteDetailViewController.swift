//
//  NoteDetailViewController.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 13/2/21.
//

import UIKit
import CoreData

class NoteDetailViewController: UIViewController, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Properties & IBOutlets
    weak var note: NoteMO?
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var titleUITextField: UITextField!
    @IBOutlet var contentUITextView: UITextView!
    
    var dataController: DataController?
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchResultsController?.delegate = self
            collectionView.reloadData()
        }
    }
    
    ///The BlockOperation class is a concrete subclass of Operation that manages the concurrent execution of one or more blocks. You can use this object to execute several blocks at once without having to create separate operation objects for each.
    private var blockOperation = BlockOperation()
    
    
    //MARK: - Initializers
    
    convenience init(dataController: DataController) {
        self.init(nibName: nil, bundle: nil)
        self.dataController = dataController
        let flowlayout = UICollectionViewFlowLayout()
        let frame = CGRect(origin: .zero, size: .zero)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowlayout)
        self.titleUITextField = UITextField()
        self.contentUITextView = UITextView()
        
        collectionView.dataSource = self
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - InitializeFetchResults
    func initializeFetchResultsController() {
        
        guard let dataController = dataController, let note = note else {return}
        let managedObjectContext = dataController.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photograph")
        let photographDateSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        
        request.predicate = NSPredicate(format: "note == %@", note)
        request.sortDescriptors = [photographDateSortDescriptor]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultsController?.delegate = self
        
        do{
            try fetchResultsController?.performFetch()
        } catch {
            fatalError("unable to fetch note details")
        }
        
    }
    
    //MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        let flowlayout = setupCollectionViewLayout()
        collectionView.setCollectionViewLayout(flowlayout, animated: false)
        titleUITextField.text = note?.title
        contentUITextView.text =  note?.contents
        initializeFetchResultsController()
        setUpNavigationItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        note?.contents = contentUITextView.text
        note?.title = titleUITextField.text
    }
    
    //MARK: - Navigation items setup
    func setUpNavigationItem() {
        let addNoteBarButtomItem = addNoteNavigationBarButtom()
        navigationItem.rightBarButtonItems = [addNoteBarButtomItem]
    }
    
    func addNoteNavigationBarButtom() -> UIBarButtonItem {
        UIBarButtonItem(title: "Add image", style: .done, target: self, action: #selector(createAndPresentPicker))
    }
    
    //MARK: - Picker functions
    @objc
    func createAndPresentPicker(){
        print("picker selected")
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
            
            if let selectedImage = info[.originalImage] as? UIImage,
               let urlImage = info[.imageURL] as? URL {
                self?.addNewPicNoteDetail(selectedImage: selectedImage, url: urlImage)
            }
        }
    }
    
    
    func addNewPicNoteDetail(selectedImage: UIImage, url: URL) {
        guard let note = note else {return}
        dataController?.addPhotograph(with: selectedImage, and: url, in: note)
    }
    
    
    //MARK: - setupCollectionView
    func setupCollectionViewLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        let numberOfColumns: CGFloat = 3
        let minimumInteritemSpacing: CGFloat = 0
        let minimumLineSpacing: CGFloat = 8
        let availableWidth = collectionView.bounds.width - 40
        let itemSize = CGSize(width:  floor(availableWidth / numberOfColumns),
                              height: 100)
        flowLayout.itemSize = itemSize
        flowLayout.minimumInteritemSpacing = minimumInteritemSpacing
        flowLayout.minimumLineSpacing = minimumLineSpacing
        flowLayout.scrollDirection = .vertical
        
        return flowLayout
    }

    //MARK: - UICollection methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Change this one..
        return fetchResultsController?.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as? PhotographCollectionViewCell,
              let photograph = fetchResultsController?.object(at: indexPath) as? PhotographMO,
              let imageData = photograph.imageData else {
            return UICollectionViewCell()
        }
        
        cell.imageDetailView.image = UIImage(data: imageData)
        
        return cell
        
    }
    
    
}


//MARK: - Extension NSFetchedResultsControllerDelegate
/// A delegate protocol that describes the methods that will be called by the associated fetched results controller when the fetch results have changed.

extension NoteDetailViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperation = BlockOperation()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let sectionIndexSet = IndexSet(integer: sectionIndex)
        
        switch type {
            case .insert:
                blockOperation.addExecutionBlock {
                    self.collectionView.insertSections(sectionIndexSet)
                }
            case .delete:
                blockOperation.addExecutionBlock {
                    self.collectionView.deleteSections(sectionIndexSet)
                }
            case .update:
                blockOperation.addExecutionBlock {
                    self.collectionView.reloadSections(sectionIndexSet)
                }
            case .move:
                break
            @unknown default:
                break
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                guard let newIndexPath = newIndexPath else {break}
                
                blockOperation.addExecutionBlock {
                    self.collectionView.insertItems(at: [newIndexPath])
                }
            case .delete:
                guard let indexPath = indexPath else {break}
                
                blockOperation.addExecutionBlock {
                    self.collectionView.deleteItems(at: [indexPath])
                }
            case .update:
                guard let indexPath = indexPath else {break}
                
                blockOperation.addExecutionBlock {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            case .move:
                guard let newIndexPath = newIndexPath, let indexPath = indexPath else {break}
                
                blockOperation.addExecutionBlock {
                    self.collectionView.moveItem(at: indexPath, to: newIndexPath)
                }
                
            @unknown default:
                break
        }
    }
    
}
    

