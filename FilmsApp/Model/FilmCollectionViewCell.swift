//
//  FilmCollectionViewCell.swift
//  FilmsApp
//
//  Created by Boris Kotov on 14.08.2023.
//

import UIKit

class FilmCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var posterPreviewImageView: UIImageView!
    @IBOutlet weak var filmTitleLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    @IBOutlet weak var closeButton: UIButton!
    
    let address = "https://image.tmdb.org/t/p/w500"
    
    var isInFavoriteList = false {
        didSet {
            self.closeButton.isHidden = !isInFavoriteList
        }
    }
    
    var image: UIImage? {
        didSet {
            if let image {
                posterPreviewImageView.contentMode = .scaleAspectFill
                posterPreviewImageView.image = image
            } else {
                posterPreviewImageView.contentMode = .scaleAspectFit
                posterPreviewImageView.image = UIImage(systemName: "film")
            }
        }
    }
    
    var data: FilmObject? {
        didSet {
            guard let data, let url = URL(string: address + data.image) else { return }
            
            URLService.global.fetchImage(url: url) { image in
                self.image = image
            }
            
            filmTitleLabel.text = data.title
            releaseYearLabel.text = String(data.releaseYear)
            ratingLabel.text = "★ " + RatingFormatter.formatter.string(for: data.rating)!
            
            alpha = data.isLiked ? 1 : 0.55
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        guard let id = data?.id else { return }
        Model.global.updateLike(id: id)
        
        UIView.animate(withDuration: 0.10, delay: 0, options: .curveLinear) {
            self.alpha = 0.55
        }
        
        closeButton.isUserInteractionEnabled = false
    }
}
