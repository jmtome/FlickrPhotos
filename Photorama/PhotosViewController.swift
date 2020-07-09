//
//  ViewController.swift
//  Photorama
//
//  Created by Juan Manuel Tome on 06/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    
    
    // Code below is commented because im implementing CollectionView in the storyBoard
    //    override func loadView() {
    //        super.loadView()
    //        view = mainView
    //        view.addSubview(imageView)
    //        setupImageView()
    //
    //    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photorama"
        collectionView.delegate = self
        collectionView.dataSource = photoDataSource
        //(collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        updateDataSource()
        

        store.fetchInterestingPhotos { photoResult -> Void in
//            switch photoResult {
//            case let .success(photos):
//                print("Successfully found \(photos.count) photos.")
//                self.photoDataSource.photos = photos
//                //                if let firstPhoto = photos.first {
//                //                    self.updateImageView(for: firstPhoto)
//            //                }
//            case let .failure(error):
//                print("Error fetching interesting photos: \(error)")
//                self.photoDataSource.photos.removeAll()
//            }
//            self.collectionView.reloadSections(IndexSet(integer: 0))
            self.updateDataSource()
        }
        
        guard let collectionView = collectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)

        collectionView.contentInsetAdjustmentBehavior = .always
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
    }
    
    let margin: CGFloat = 10
    let cellsPerRow = 4
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
   
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let collectionView = collectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
               let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
               let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
               flowLayout.itemSize =  CGSize(width: itemWidth, height: itemWidth)
    }
    //MARK: - Properties
    var store: PhotoStore!
    var photoDataSource = PhotoDataSource()
    
    //    func updateImageView(for photo: Photo) {
    //        store.fetchImage(for: photo) { imageResult in
    //            switch imageResult {
    //            case let .success(image):
    //                self.imageView.image = image
    //            case let .failure(error):
    //                print("Error downloading image: \(error)")
    //            }
    //        }
    //    }
    
    //MARK: - UIComponents
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    let mainView: UIView! = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .systemBackground
        
        return view
    }()
   
}

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]
        let destinationVC = PhotoInfoViewController()
        destinationVC.photo = photo
        destinationVC.store = store
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]
        
        //Download image data which could take some time
        store.fetchImage(for: photo) { (result) -> Void in
            // The index path for the photo might have changed between the time the request started and finished
            // so find the most recent index path
            
            guard let photoIndex = self.photoDataSource.photos.firstIndex(of: photo),
                case let .success(image) = result else { return }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            // when the request finishes, find the current cell for this photo,
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(displaying: image)
            }
        }
    }
    
    private func updateDataSource() {
        store.fetchAllPhotos { (photosResult) in
            switch photosResult {
                case let .success(photos):
                    self.photoDataSource.photos = photos
                case .failure:
                    self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}


// the code below is for using a segue named "showPhoto" , but i used didSelectItemForIndex
//extension PhotosViewController {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segue.identifier {
//        case "showPhoto":
//            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
//                let photo = photoDataSource.photos[selectedIndexPath.row]
//                let destinationVC = segue.destination as! PhotoInfoViewController
//                destinationVC.photo = photo
//                destinationVC.store = store
//            }
//        default:
//            preconditionFailure("Unexpected segue identifier")
//        }
//    }
//}
