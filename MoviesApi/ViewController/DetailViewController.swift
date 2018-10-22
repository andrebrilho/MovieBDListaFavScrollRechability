//
//  DetailViewController.swift
//  MoviesApi
//
//  Created by André Brilho on 09/09/2018.
//  Copyright © 2018 André Brilho. All rights reserved.
//

import UIKit
import AlamofireImage

class DetailViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgMovie: UIImageView!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var lblInfo1: UILabel!
    @IBOutlet weak var lblInfo2: UILabel!
    @IBOutlet weak var lblInfo3: UILabel!
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var starImage: UIImageView!
    
    var movie:MovieModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if movie.favorito {
            starImage.image = UIImage.init(named: "star")
        }else{
            starImage.image = UIImage.init(named: "starEmpty")
        }
        
        
        lblTitle.text = movie.original_title
        txtDesc.text = movie.overview
        imgMovie.image = nil
        imgMovie.af_cancelImageRequest()
        
        let poster_path = movie.poster_path
        let url = URL(string: Constants.baseImageUrl + "500" + poster_path)
            actIndicator.startAnimating()
        imgMovie.af_setImage(withURL: url!, imageTransition: .crossDissolve(0.2), completion: {(_) in
                self.actIndicator.stopAnimating()
            })
    }
    
    @IBAction func btnVoltar(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func addFavBeer(_ sender: Any) {
        do {
            AppDelegate.realmMovies.beginWrite()
            movie.favorito = !movie.favorito
            try
                AppDelegate.realmMovies.commitWrite()
        }catch {
            print("erro para favoritar")
        }
        if  movie.favorito {
            starImage.image = UIImage.init(named: "star")
        }else{
            starImage.image = UIImage.init(named: "starEmpty")
        }
    }
    
    
}

