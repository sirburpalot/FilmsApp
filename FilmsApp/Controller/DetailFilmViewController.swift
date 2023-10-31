//
//  DetailFilmViewController.swift
//  FilmsApp
//
//  Created by Boris Kotov on 14.08.2023.
//

import UIKit
import Lightbox

class DetailFilmViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var filmTitleLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var galleryCollection: UICollectionView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    var transition = RoundingTransition()
    
    let service = URLService.global
    
    let addressPrefix = "https://image.tmdb.org/t/p/w500"
    
    var displayedItem: FilmObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = self.displayedItem.image
        guard let posterURL = URL(string: self.addressPrefix + image) else { return }
            
        self.service.fetchImage(url: posterURL) { image in
            self.posterImageView.contentMode = .scaleAspectFill
            self.posterImageView.image = image
        }
            
        if self.displayedItem.screenshots.isEmpty {
            URLService.global.fetchScreenshotList(movieId: self.displayedItem.id) { screenshots in
                DispatchQueue.main.async {
                    self.displayedItem.screenshots = screenshots
                    self.galleryCollection.reloadData()
                }
            }
        }
        
        self.prepareControls()
    }

    private func prepareControls() {
        self.filmTitleLabel.text = self.displayedItem.title
        self.releaseYearLabel.text = String(self.displayedItem.releaseYear)
        self.ratingLabel.text = "★ " + RatingFormatter.formatter.string(for: self.displayedItem.rating)!
            
        self.descriptionTextView.text = self.displayedItem.overview
            
        self.likeButton.configuration?.image = UIImage(systemName: self.displayedItem.isLiked ? "heart.fill" : "heart")
    }
    
    @IBAction func tapGestureAction(_ sender: UITapGestureRecognizer) {
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        Model.global.updateLike(id: displayedItem.id)
        likeButton.configuration?.image = UIImage(systemName: displayedItem.isLiked ? "heart.fill" : "heart")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modalTap" {
            guard let destVC = segue.destination as? PosterFullViewController else { return }
            destVC.displayedItem = displayedItem
            
            destVC.transitioningDelegate = self
            destVC.modalPresentationStyle = .custom
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionProfile = .show
        transition.start = posterImageView.center
        transition.roundColor = .lightGray
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionProfile = .cancel
        transition.start = posterImageView.center
        transition.roundColor = .lightGray
            
        return transition
    }
}

extension DetailFilmViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailFilmCell", for: indexPath) as? DetailFilmViewCell else {
            return UICollectionViewCell()
        }
        
        cell.image = nil
        
        let screenshot = displayedItem.screenshots[indexPath.item]
        let screenshotURL = URLService.global.screenshotURL(filePath: screenshot.filePath, format: "w200")
        
        URLService.global.fetchImage(url: screenshotURL) { [weak cell] image in
            guard let cell else { return }
            cell.image = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayedItem.screenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !displayedItem.screenshots.isEmpty else { return }
        
        let images = displayedItem.screenshots.map { screenshot in
            LightboxImage(imageURL: URLService.global.screenshotURL(filePath: screenshot.filePath, format: "original"))
        }
        
        let vc = LightboxController(images: images)
        vc.dynamicBackground = true
        vc.goTo(indexPath.item, animated: false)
        
        present(vc, animated: true)
    }
}
