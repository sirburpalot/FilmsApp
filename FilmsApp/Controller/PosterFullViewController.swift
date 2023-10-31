//
//  PosterFullViewController.swift
//  FilmsApp
//
//  Created by Boris Kotov on 24.08.2023.
//

import UIKit

class PosterFullViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
  
    var displayedItem: FilmObject!
    
    let addressPrefix = "https://image.tmdb.org/t/p/original"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = displayedItem.image
        guard let posterURL = URL(string: self.addressPrefix + image) else { return }
        
        URLService.global.fetchImage(url: posterURL) { image in
            self.posterImageView.image = image
        }
    }

    @IBAction func closeButtonPress(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
