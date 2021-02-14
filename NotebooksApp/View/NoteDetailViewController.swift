//
//  NoteDetailViewController.swift
//  NotebooksApp
//
//  Created by Tim Acosta on 13/2/21.
//

import Foundation
import UIKit

class NoteDetailViewController: UIViewController, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var note: NoteMO?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleUITextField: UITextField!
    @IBOutlet weak var contentUITextView: UITextView!
    
    //private var blockOperation = BlockOperation()
    
    //MARK: - Properties
    var dataController: DataController?
    
    convenience init(dataController: DataController) {
        self.init(nibName: nil, bundle: nil)
        self.dataController = dataController
        
        self.titleUITextField = UITextField()
        self.contentUITextView = UITextView()
    }
    
    override func viewDidLoad() {
        <#code#>
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //
    }
    
    
}
 
