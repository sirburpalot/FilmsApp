//
//  Model.swift
//  FilmsApp
//
//  Created by Boris Kotov on 11.09.2023.
//

import Foundation
import RealmSwift

class FilmObject: Object, Decodable {
    @Persisted(primaryKey: true) var id: Int = 0
    @Persisted var image: String = ""
    @Persisted var title: String = ""
    @Persisted var overview: String = ""
    @Persisted var releaseDate: String = ""
    @Persisted var rating: Double = 0
    @Persisted var isLiked: Bool = false

    var screenshots: [Screenshot] = []
    
    var releaseYear: Int {
        Int(releaseDate.prefix(4)) ?? 0
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case image = "poster_path"
        case title = "original_title"
        case overview
        case releaseDate = "release_date"
        case rating = "vote_average"
    }
}

class Model {
    enum SortField: String {
        case title
        case releaseDate
        case rating
    }
    
    enum SortOrder {
        case ascending
        case descending
    }
    
    static let global = Model()

    private var realmConfig: Realm.Configuration
    private var realm: Realm
    
    private (set) lazy var filmObjects: Results<FilmObject> = realm.objects(FilmObject.self)
    private (set) lazy var mainViewObjects = filmObjects.sorted(byKeyPath: "title", ascending: true)
    
    private (set) var likedFilmObjects: [FilmObject] = []
            
    var sortField: SortField = .title
    var sortOrder: SortOrder = .ascending
    
    init(realmConfig: Realm.Configuration = .defaultConfiguration) {
        self.realmConfig = realmConfig
        realm = try! Realm(configuration: realmConfig)
    }
    
    func resetMainView() {
        mainViewObjects = filmObjects.sorted(byKeyPath: sortField.rawValue, ascending: sortOrder == .ascending)
    }
    
    func search(searchTextValue: String) {
        let predicate = NSPredicate(format: "title CONTAINS [c]%@", searchTextValue)
        mainViewObjects = filmObjects.filter(predicate)
    }
    
    func showLikedFilms() {
        let predicate = NSPredicate(format: "isLiked = true")
        let objects = filmObjects.filter(predicate)
        
        likedFilmObjects = Array(objects)
    }
    
    func updateLike(id: Int) {
        guard let film = filmObjects.first(where: { $0.id == id }) else { return }
        
        do {
            try realm.write ({
                film.isLiked.toggle()
            })
        } catch {
            print("Error saving liked status: \(error)")
        }
    }
    
    func loadFilms(_ filmObjects: [FilmObject]) {
        do {
            let realm = try Realm(configuration: realmConfig)
            
            let predicate = NSPredicate(format: "isLiked = true")
            let likedIds = realm.objects(FilmObject.self).filter(predicate).map { $0.id }

            try realm.write({
                for filmObject in filmObjects {
                    filmObject.isLiked = likedIds.contains(filmObject.id)
                    realm.add(filmObject, update: .all)
                }
            })
        } catch let error {
            print("Error while importing film objects: \(error)")
        }
    }
    
}
