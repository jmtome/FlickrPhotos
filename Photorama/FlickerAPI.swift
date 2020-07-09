//
//  FlickerAPI.swift
//  Photorama
//
//  Created by Juan Manuel Tome on 07/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import Foundation


enum EndPoint: String {
    case interestingPhotos = "flickr.interestingness.getList"
    
}

struct FlickrResponse: Codable {
    //let photos: FlickrPhotosResponse
    let photosInfo: FlickrPhotosResponse
    
    enum CodingKeys: String, CodingKey {
        case photosInfo = "photos"
    }
    
    
}
struct FlickrPhotosResponse: Codable {
    //let photo: [Photo]
    let photos: [FlickrPhoto]
    
    enum CodingKeys: String, CodingKey {
        case photos = "photo"
    }
}

struct FlickrAPI {
    
    
    
    private static let baseURLString = "https://api.flickr.com/services/rest"
    
    private static let apiKey = "a6d819499131071f158fd740860a5a88"
    
    private static func flickrURL(endpoint: EndPoint,
                                  parameters: [String:String]? ) -> URL {
        
        var components = URLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "method": endpoint.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": apiKey
        ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
                
            }
        }
        components.queryItems = queryItems
        //print(components.url!)
        return components.url!
        
    }
    static var interestingPhotosURL: URL {
        return flickrURL(endpoint: .interestingPhotos, parameters: ["extras" : "url_z,date_taken"])
    }
    
    static func photos(fromJSON data: Data) -> Result<[FlickrPhoto], Error> {
        do {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            let flickrResponse = try decoder.decode(FlickrResponse.self, from: data)
            let photos = flickrResponse.photosInfo.photos.filter { (photo) in
                photo.remoteURL != nil
            }
            return .success(photos)
        } catch {
            return .failure(error)
        }
    }
    
}



/*
 “https://api.flickr.com/services/rest/?
 method=flickr.interestingness.getList
 &api_key=a6d819499131071f158fd740860a5a88
 &extras=url_z,date_taken
 &format=json
 &nojsoncallback=1”
 */

/*
 https://api.flickr.com/services/rest?
 nojsoncallback=1
 &method=flickr.interestingness.getList
 &api_key=a6d819499131071f158fd740860a5a88
 &format=json
 &extras=url_z,date_taken
 */
