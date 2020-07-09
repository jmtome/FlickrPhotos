//
//  TagDataSource.swift
//  Photorama
//
//  Created by Juan Manuel Tome on 09/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import UIKit
import CoreData


class TagDataSource: NSObject, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) as! MyTagsViewCell
        
        let tag = tags[indexPath.row]
        cell.textLabel?.text = tag.name
        cell.detailTextLabel?.text = "soy pepe"
        return cell
    }
    

    //MARK: - Properties
    var tags: [Tag] = [Tag]()
    
    
    
}
