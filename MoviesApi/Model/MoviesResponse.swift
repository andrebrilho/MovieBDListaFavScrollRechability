//
//  MoviesResponse.swift
//  MoviesApi
//
//  Created by André Brilho on 09/09/2018.
//  Copyright © 2018 André Brilho. All rights reserved.
//

import Foundation

class MoviesResponse: Decodable {
    
    var page:Int?
    var total_results: Int?
    var total_pages: Int?
    var results:[MovieModel]!
    
}
