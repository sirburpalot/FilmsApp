//
//  DetailFilmViewCell.swift
//  FilmsApp
//
//  Created by Boris Kotov on 27.09.2023.
//

import UIKit

class DetailFilmViewCell: UICollectionViewCell {
    @IBOutlet weak var frameImageView: UIImageView!
    
    var image: UIImage? {
        didSet {
            if let image {
                frameImageView.contentMode = .scaleAspectFill
                frameImageView.image = image
            } else {
                frameImageView.contentMode = .scaleAspectFit
                frameImageView.image = UIImage(systemName: "film")
            }
        }
    }
}
