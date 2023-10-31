//
//  FavoriteFilmsViewController.swift
//  FilmsApp
//
//  Created by Boris Kotov on 14.08.2023.
//

import UIKit

class FavoriteFilmsViewController: UIViewController {
    @IBOutlet weak var favoriteFilmsCollectionView: UICollectionView!
    
    @IBOutlet weak var emptyTextLabel: UILabel!
    
    let model = Model.global
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        favoriteFilmsCollectionView.delegate = self
        favoriteFilmsCollectionView.dataSource = self
        
        let xibCell = UINib(nibName: "FilmCollectionViewCell", bundle: nil)
        
        favoriteFilmsCollectionView.register(xibCell, forCellWithReuseIdentifier: "FilmCell")
        
        DispatchQueue.main.async {
            self.model.showLikedFilms()
            self.emptyTextLabel.isHidden = !self.model.likedFilmObjects.isEmpty
            self.favoriteFilmsCollectionView.reloadData()
        }
    }
}

extension FavoriteFilmsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.model.likedFilmObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilmCell", for: indexPath) as? FilmCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.data = model.likedFilmObjects[indexPath.item]
        cell.isInFavoriteList = true
                
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let destViewController = storyboard?.instantiateViewController(withIdentifier: "DetailFilmViewControllerS") as? DetailFilmViewController else { return }
        destViewController.displayedItem = model.likedFilmObjects[indexPath.item]
        
        navigationController?.pushViewController(destViewController, animated: true)
    }
}
