//
//  ImageStore.swift
//  LootLogger
//
//  Created by Juan Manuel Tome on 04/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import UIKit

class ImageStore {
    let cache = NSCache<NSString, UIImage>()
    
    func setImage(_ image: UIImage, forkey key: String) {
        cache.setObject(image, forKey: key as NSString)
        //create full URL for the image
        let url = imageURL(forKey: key)
        if let data = image.jpegData(compressionQuality: 0.5) {
            //write it to full URL
            try? data.write(to: url)
        }
        
    }
    func image(forKey key: String) -> UIImage? {
//        return cache.object(forKey: key as NSString)
//
        if let existingImage = cache.object(forKey: key as NSString) {
            return existingImage
        }
        let url = imageURL(forKey: key)
        guard let imageFromDisk = UIImage(contentsOfFile: url.path) else { return nil }
        
        cache.setObject(imageFromDisk, forKey: key as NSString)
        return imageFromDisk
    }
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        
        let url = imageURL(forKey: key)
        do {
            try FileManager.default.removeItem(at: url)
            
        } catch {
            print("Error removing image from disk \(error)")
        }
    }
    func imageURL(forKey key: String) -> URL {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent(key)
    }
    
}
