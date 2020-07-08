//
//  PhotoStore.swift
//  Photorama
//
//  Created by Juan Manuel Tome on 07/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import UIKit

enum PhotoError: Error {
    case imageCreationError
    case missingImageURL
}
class PhotoStore {
    
    let imageStore = ImageStore()
    
    
    func fetchImage(for photo: Photo,
                    completion: @escaping(Result<UIImage,Error>) -> Void) {
        let photoKey = photo.photoID
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
        
            let result = self.processPhotosRequest(data: data, error: error)
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }.resume()
        
        
    }
    
    
    
    private func processPhotosRequest(data: Data?,
                                      error: Error?) -> Result<[Photo],Error> {
        guard let jsonData = data else { return .failure(error!) }
        return FlickrAPI.photos(fromJSON: jsonData)
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
