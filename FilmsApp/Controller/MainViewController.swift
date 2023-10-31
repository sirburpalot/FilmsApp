//
//  ViewController.swift
//  FilmsApp
//
//  Created by Boris Kotov on 14.08.2023.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {

    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var sortBtn: UIBarButtonItem!
    
    var searchController = UISearchController()
    
    let model = Model.global
    
    let service = URLService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("Search Film", comment: "Search field placeholder")
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let xibCell = UINib(nibName: "FilmCollectionViewCell", bundle: nil)
        
        mainCollectionView.register(xibCell, forCellWithReuseIdentifier: "FilmCell")
        
        sortBtn.menu = generateSortingMenu()
        
        service.fetchMovieList { filmObjects in
            self.model.loadFilms(filmObjects)
            
            DispatchQueue.main.async {
                self.mainCollectionView.reloadData()
            }
        }
    }

    private func generateSortingMenu() -> UIMenu {
        let sortOptions: [(actionTitle: String, field: Model.SortField, order: Model.SortOrder)] = [
            ("Title (asc.)", .title, .ascending),
            ("Title (desc.)", .title, .descending),
            ("Newest First", .releaseDate, .descending),
            ("Oldest First", .releaseDate, .ascending),
            ("Highest Rated", .rating, .descending),
            ("Lowest Rated", .rating, .ascending)
        ]
        
        let menuActions = sortOptions.map { option in
            let isChecked = self.model.sortField == option.1 && self.model.sortOrder == option.2
            
            return UIAction(title: NSLocalizedString(option.actionTitle, comment: ""),
                     image: isChecked ? UIImage(systemName: "checkmark") : nil) { [weak self] action in
                guard let self else { return }
                
                self.model.sortField = option.field
                self.model.sortOrder = option.order
                self.model.resetMainView()
                
                self.reloadAndResetPosition(animated: true)
                
                self.sortBtn.menu = generateSortingMenu()
            }
        }
        
        return UIMenu(title: NSLocalizedString("Sort By", comment: "Sorting menu title"), options: .displayInline, children: menuActions)
    }
    
    func reloadAndResetPosition(animated: Bool = false) {
        mainCollectionView.reloadData()
        
        if mainCollectionView.numberOfItems(inSection: 0) > 0 {
            self.mainCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: animated)
        }
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.mainViewObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilmCell", for: indexPath) as? FilmCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let item = model.mainViewObjects[indexPath.item]
        cell.data = item
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let destViewController = storyboard?.instantiateViewController(withIdentifier: "DetailFilmViewControllerS") as? DetailFilmViewController else { return }
        destViewController.displayedItem = model.mainViewObjects[indexPath.item]
        
        navigationController?.pushViewController(destViewController, animated: true)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count != 0 {
            model.search(searchTextValue: searchText)
        } else {
            model.resetMainView()
        }

        DispatchQueue.main.async {
            self.reloadAndResetPosition()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        model.resetMainView()
        
        DispatchQueue.main.async {
            self.reloadAndResetPosition(animated: true)
        }
    }
}
