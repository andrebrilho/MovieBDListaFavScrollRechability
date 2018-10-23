//
//  ViewController.swift
//  MoviesApi
//
//  Created by André Brilho on 09/09/2018.
//  Copyright © 2018 André Brilho. All rights reserved.
//

import UIKit
import RealmSwift
import MBProgressHUD
import SystemConfiguration

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var collectionMovies: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lblFav: UIBarButtonItem!
    @IBOutlet weak var lblAtualizar: UIBarButtonItem!
    
    var numberPage:Int = 1
    var movies:[MovieModel] = []
    var isError:Bool = false
    var filterFavoritos:Bool = false
    let updateMoviesDefaultPag:Int = 1
    var enableScrollInfinito:Bool = false
    var hud: MBProgressHUD = MBProgressHUD()
    var filterData = [MovieModel]()
    var isSearching:Bool = false
    var warningCont = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionMovies.dataSource = self
        collectionMovies.delegate = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        registerCells()
        getMovies(page: numberPage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionMovies.reloadData()
    }
    
    func getMovies(page:Int){
        alertInternet()
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        MoviesApi.fetchMovies(NumberPage: page, refresh: false, sucess: { (movies) in
            self.isError = false
            self.movies.append(contentsOf: movies)
            self.collectionMovies.reloadData()
        }) { (error) in
            self.isError = true
            self.collectionMovies.reloadData()
            print(error)
        }
        self.hud.hide(animated: true)
    }
    
    func registerCells(){
        collectionMovies.register(UINib(nibName: "ItemMovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemMovieCell")
        collectionMovies.register(UINib(nibName: "ErrorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ErrorCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return filterData.count
        }
        if isError || movies.count == 0 {
            return 1
        }
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isError || indexPath.row == movies.count {
            return CGSize(width: collectionView.frame.width, height: 45)
        }
        return CGSize(width: 103, height: 164)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isError || movies.count == 0, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ErrorCell", for: indexPath) as? ErrorCollectionViewCell {
            return cell
        }
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemMovieCell", for: indexPath) as? ItemMovieCollectionViewCell {
            if isSearching {
                cell.movie = filterData[indexPath.row]
            }else{
                cell.movie = movies[indexPath.row]
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            collectionMovies.reloadData()
        }else{
            isSearching = true
            filterData = movies.filter({$0.title.lowercased().prefix(searchText.count) == searchText.lowercased()})
            print(filterData)
            collectionMovies.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        do {
            AppDelegate.realmMovies.beginWrite()
            let movie = movies[indexPath.row]
            AppDelegate.realmMovies.delete(movie)
            try
                AppDelegate.realmMovies.commitWrite()
            movies.remove(at: indexPath.row)
            collectionMovies.reloadData()
        }catch {
            //TODO:
            print("erro ao excluir elemento")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Reachability.isConnectedToNetwork() {
            if !isError && movies.count > 0, let detailVC = storyboard?.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController {
                if isSearching {
                    detailVC.movie = filterData[indexPath.row]
                }else{
                    detailVC.movie = movies[indexPath.row]
                    present(detailVC, animated: true)
                }
            }else{
                print("erro")
            }
        }else{
            alertInternet()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !enableScrollInfinito {
            if !isError && movies.count > 0 {
                if indexPath.row == movies.count - 1 {
                    if Reachability.isConnectedToNetwork() {
                        numberPage += 1
                        print(numberPage)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            MoviesApi.fetchMovies(NumberPage: self.numberPage, refresh: true, sucess: { (movies) in
                                self.isError = false
                                self.movies.append(contentsOf: movies)
                                self.collectionMovies.reloadData()
                                self.hud.hide(animated: true, afterDelay: 0.2)
                            }) { (error) in
                                self.isError = true
                                self.collectionMovies.reloadData()
                                print(error)
                                self.hud.hide(animated: true)
                            }
                        }
                    }
                }else{
                    if !warningCont {
                        warningCont = true
                        alertInternet()
                    }
                   
                }
            }
        }
    }
    
    func createNewBD(){
        do {
            AppDelegate.realmMovies.beginWrite()
            AppDelegate.realmMovies.deleteAll()
            try
                AppDelegate.realmMovies.commitWrite()
        }catch {
            print("erro ao processar exclusão dos dados do BD")
        }
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            MoviesApi.fetchMovies(NumberPage: self.updateMoviesDefaultPag, refresh: false, sucess: { (movies) in
                self.movies = movies
                DispatchQueue.main.async {
                self.collectionMovies.reloadData()
                self.hud.hide(animated: true)
                }
            }) { (error) in
                self.isError = true
                self.collectionMovies.reloadData()
                print(error)
            }
        }
    }
    
    
    
    @IBAction func atualizarBtn(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            alertInternet()
        }
        showAlert(message: Constants.messageForDeleteBD, completion: true)
    }
    
    
    @IBAction func favoritosBtn(_ sender: Any) {
        changeTitlesAndButtons()
        filterFavoritos = !filterFavoritos
        enableScrollInfinito = !enableScrollInfinito
        let moviesResult: Results<MovieModel>!
        if filterFavoritos {
            moviesResult = AppDelegate.realmMovies.objects(MovieModel.self).filter("favorito == true").sorted(byKeyPath: "title")
        }else{
            moviesResult = AppDelegate.realmMovies.objects(MovieModel.self).sorted(byKeyPath: "title")
        }
        movies = [MovieModel]()
        for movie in moviesResult {
            movies.append(movie)
        }
        collectionMovies.reloadData()
    }
    
    
    //Mark: Helpers
    func changeTitlesAndButtons(){
        if lblFav.title == "Voltar" {
            self.lblFav.title = "Favoritos"
            self.lblAtualizar.isEnabled = true
            self.lblAtualizar.title = "Atualizar"
            self.title = "Filmes"
        } else {
            self.title = "Favoritos"
            self.lblFav.title = "Voltar"
            self.lblAtualizar.isEnabled = false
            self.lblAtualizar.title = ""
        }
    }
    
    func showAlert(message:String, completion:Bool){
        
        let refreshAlert = UIAlertController(title: "Alerta", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            if completion {
                self.createNewBD()
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func alertInternet(){
        if Reachability.isConnectedToNetwork(){
            print("internet OK")
        }else{
            showAlert(message: Constants.messageForNoInternet, completion: false)
        }
    }
}

