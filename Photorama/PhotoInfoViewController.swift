//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Juan Manuel Tome on 08/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {

    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
        self.view.addSubview(imageView)
        setupImageView()
    }
    private func setupImageView() {
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchImage(for: photo) { (result) -> Void in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for \(error)")
            }
        }
        

    }
    
    
    //MARK: - Properties
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!

   
   //MARK: - UI Elements
    let imageView: UIImageView! = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

}
