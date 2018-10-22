//
//  MovieModel.swift
//  MoviesApi
//
//  Created by André Brilho on 09/09/2018.
//  Copyright © 2018 André Brilho. All rights reserved.
//

import Foundation
import RealmSwift

class MovieModel: Object, Codable {
    
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var popularity = 0.0
    @objc dynamic var poster_path = ""
    @objc dynamic var original_title = ""
    @objc dynamic var overview = ""
    @objc dynamic var favorito = false
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case popularity
        case poster_path
        case overview
    }
    
    @objc override public class func primaryKey() -> String {
        return "id"
    }
    
}
