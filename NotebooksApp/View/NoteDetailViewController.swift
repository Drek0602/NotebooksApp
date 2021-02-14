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
        
        //create fetchRequest
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
    
    //MARK: - AddPicToNote TODO
    func addNewPicNoteDetail(selectedImage: UIImage, url: URL?) {}

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
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as? PictureCollectionViewCell,
              let picture = fetchResultsController?.object(at: indexPath) as? PhotographMO,
              let imageData = picture.imageData else {
            return UICollectionViewCell()
        }
        
        cell.imageDetailView.image = UIImage(data: imageData)
        
        return cell
        
    }
    
    
}
 
extension NoteDetailViewController: NSFetchedResultsControllerDelegate {
    
}
