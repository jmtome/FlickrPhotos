//
//  PhotoStore.swift
//  Photorama
//
//  Created by Juan Manuel Tome on 07/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import UIKit
import CoreData

enum PhotoError: Error {
    case imageCreationError
    case missingImageURL
}
class PhotoStore {
    
    let imageStore = ImageStore()
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores {(description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
            
        }
        return container
    }()
    
    func fetchImage(for photo: Photo,
                    completion: @escaping(Result<UIImage,Error>) -> Void) {
        guard let photoKey = photo.photoID else { preconditionFailure("Photo expected to have a PhotoID") }
        if let image = imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
            
        }
        
        guard let photoURL = photo.remoteURL else {
            completion(.failure(PhotoError.missingImageURL))
            return
        }
        let request = URLRequest(url: photoURL)
        let task = session.dataTask(with: request) { data, response, error in
            let result = self.processImageRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
                let response = response as! HTTPURLResponse
                print("AllHeaderFields: \(response.allHeaderFields)")
                print("StatusCode:  \(response.statusCode)")
            }
            
        }.resume()
    }
    
    private func processImageRequest(data: Data?,
                                     error: Error?) -> Result<UIImage, Error> {
        guard let imageData = data,
            let image = UIImage(data: imageData) else {
                //couldnt create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        
        return .success(image)
    }
    
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchInterestingPhotos(completion: @escaping (Result<[Photo],Error>) -> Void ) {
        let url = FlickrAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data,response,error in
            self.processPhotosRequest(data: data, error: error) { (result) in
                OperationQueue.main.addOperation {
                    completion(result)
                }
            }
        }.resume()
        
        
    }
    
    
    
    
    private func processPhotosRequest(data: Data?,
                                      error: Error?,
                                      completion: @escaping (Result<[Photo],Error>) -> Void ) {
        guard let jsonData = data else { return completion(.failure(error!)) }
        
        //        let context = persistentContainer.viewContext
        
        persistentContainer.performBackgroundTask { (context) in
           
            switch FlickrAPI.photos(fromJSON: jsonData) {
            case let .success(flickrPhotos):
                let photos = flickrPhotos.map { flickrPhoto -> Photo in
                    
                    
                    let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
                    
                    let predicate = NSPredicate(format: "\(#keyPath(Photo.photoID)) == \(flickrPhoto.photoID)")
                    
                    fetchRequest.predicate = predicate
                    var fetchedPhotos: [Photo]?
                    
                    context.performAndWait {
                        try? fetchRequest.execute()
                    }
                    
                    if let existingPhoto = fetchedPhotos?.first {
                        return existingPhoto
                    }
                    
                    var photo: Photo!
                    context.performAndWait {
                        photo = Photo(context: context)
                        photo.title = flickrPhoto.title
                        photo.photoID = flickrPhoto.photoID
                        photo.remoteURL = flickrPhoto.remoteURL
                        photo.dateTaken = flickrPhoto.dateTaken
                    }
                    return photo
                }
                do {
                    try context.save()
                } catch {
                    print("Error saving to core data \(error)")
                    completion(.failure(error))
                }
                
//                completion(.success(photos))
                let photoIDs = photos.map { (photo) in
                    photo.objectID
                }
                let viewContext = self.persistentContainer.viewContext
                let viewContextPhotos = photoIDs.map { (photo) in
                    viewContext.object(with: photo)
                } as! [Photo]
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
        //        return FlickrAPI.photos(fromJSON: jsonData)
    }
    
    func fetchAllTags(completion: @escaping (Result<[Tag],Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allTags = try fetchRequest.execute()
                completion(.success(allTags))
            } catch {
                completion(.failure(error))
            }
        }
    }
    func fetchAllPhotos(completion: @escaping (Result<[Photo],Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}


/*
 //Code to use if we wanted to send, POST, an image to an imaginary site, using URLRequest
 
 if let someURL = URL(string: "http://www.photos.example.com/upload") {
 let image = profileImage()
 let data = image.pngData()
 
 var req = URLRequest(url: someURL)
 
 // Adds the HTTP body data and automatically sets the content-length header
 req.httpBody = data
 
 // Changes the HTTP method in the request line
 req.httpMethod = "POST"
 
 // If you wanted to set a request header, such as the Accept header
 req.setValue("text/json", forHTTPHeaderField: "Accept")
 }
 */


/*
 private func processPhotosRequest(data: Data?,
                                   error: Error?,
                                   completion: @escaping (Result<[Photo], Error>) -> Void) {
     guard let jsonData = data else {
         completion(.failure(error!))
         return
     }

     persistentContainer.performBackgroundTask {
         (context) in
         switch FlickrAPI.photos(fromJSON: jsonData) {
         case let .success(flickrPhotos):
             let photos = flickrPhotos.map { flickrPhoto -> Photo in
                 let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
                 let predicate = NSPredicate(
                     format: "\(#keyPath(Photo.photoID)) == \(flickrPhoto.photoID)"
                 )
                 fetchRequest.predicate = predicate
                 var fetchedPhotos: [Photo]?
                 context.performAndWait {
                     fetchedPhotos = try? fetchRequest.execute()
                 }
                 if let existingPhoto = fetchedPhotos?.first {
                     return existingPhoto
                 }

                 var photo: Photo!
                 context.performAndWait {
                     photo = Photo(context: context)
                     photo.title = flickrPhoto.title
                     photo.photoID = flickrPhoto.photoID
                     photo.remoteURL = flickrPhoto.remoteURL
                     photo.dateTaken = flickrPhoto.dateTaken
                 }
                 return photo
             }
             completion(.success(photos))
         case let .failure(error):
             completion(.failure(error))
         }
     }
 }
 */
