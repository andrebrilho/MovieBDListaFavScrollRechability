//
//  MoviesApi.swift
//  MoviesApi
//
//  Created by André Brilho on 09/09/2018.
//  Copyright © 2018 André Brilho. All rights reserved.
//

import Foundation

class MoviesApi {
    
    static func fetchMovies(NumberPage:Int, refresh: Bool, sucess: @escaping ([MovieModel]) -> Void, failure: @escaping (Error) -> Void) {
        
        if let url = URL(string: Constants.baseURL + Constants.moviePath + Constants.apiKey + "&page=" + String(NumberPage)){
            print(url)
            let request = URLRequest(url: url)
            if !refresh {
                
                let moviesRealm = AppDelegate.realmMovies.objects(MovieModel.self).sorted(byKeyPath: "title")
                if !moviesRealm.isEmpty{
                    var movies = [MovieModel]()
                    for movie in moviesRealm {
                        movies.append(movie)
                    }
                    print("carregando movies do BD")
                    sucess(movies)
                    return
                }
            }

            URLSession.shared.dataTask(with: request, completionHandler : { (data, response, error) in
                if let erro = error {
                    DispatchQueue.main.async {
                        failure(erro)
                    }
                }else{
                    if let data = data {
                        do {
                            var movies = try JSONDecoder().decode(MoviesResponse.self, from: data)
                            var moviesCount = movies.results!.count
                            DispatchQueue.main.async {
                                do {
                                    var moviesToInsert = [MovieModel]()
                                    for i in 0..<moviesCount{
                                        print("removendo item primaryKey")
                                        let movie = movies.results![i]
                                        if let moviesRealm = AppDelegate.realmMovies.object(ofType: MovieModel.self, forPrimaryKey: movie.id){
                                            movies.results![i] = moviesRealm
                                        }else{
                                            print("persistindo item no BD")
                                            moviesToInsert.append(movie)
                                        }
                                    }
                                    print("salvando dados no BD")
                                    AppDelegate.realmMovies.beginWrite()
                                    AppDelegate.realmMovies.add(moviesToInsert)
                                    try
                                        AppDelegate.realmMovies.commitWrite()
                                        sucess(movies.results!)
                                    }catch{
                                    print("erro ao salvar BD")
                                    }
                                }
                        }catch {
                            DispatchQueue.main.async {
                                print("erro decode json")
                                failure(error)
                            }
                        }
                    }
                }
            }).resume()
        }else{
            print("error url")
        }
    }
    
}
