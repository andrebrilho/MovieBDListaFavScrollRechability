//
//  ItemMovieCollectionViewCell.swift
//  MoviesApi
//
//  Created by André Brilho on 09/09/2018.
//  Copyright © 2018 André Brilho. All rights reserved.
//

import UIKit
import AlamofireImage

class ItemMovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgCell: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgStar: UIImageView!
    
    var movie: MovieModel! {
        didSet {
            setData()
        }
    }
    
    fileprivate func setData() {
        
        if movie.favorito {
            imgStar.image = UIImage.init(named: "star")
        }else{
            imgStar.image = nil
        }
        
        lblName.text = movie.title
        imgCell.image = nil
        imgCell.af_cancelImageRequest()
        
        let poster_path = movie.poster_path
        let url = URL(string: Constants.baseImageUrl + "185" + poster_path)
            actIndicator.startAnimating()
            imgCell.af_setImage(withURL: url!, imageTransition: .crossDissolve(0.2), completion: {(_) in
                self.actIndicator.stopAnimating()
            })
    }
}

