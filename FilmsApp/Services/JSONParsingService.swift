//
//  JSONParsingService.swift
//  FilmsApp
//
//  Created by Boris Kotov on 24.10.2023.
//

import Foundation
import RealmSwift

class JSONParsingService {
    private let decoder = JSONDecoder()
    
    func parseMovieList(data: Data) -> [FilmObject]? {
        do {
            let movieList = try decoder.decode(MovieList.self, from: data)
            return movieList.results
        } catch let error {
            print("Error while parsing movie list: \(error)")
            return nil
        }
    }
    
    func parseScreenshotList(data: Data) -> [Screenshot]? {
        do {
            let screenshotList = try decoder.decode(ScreenshotList.self, from: data)
            return screenshotList.backdrops
        } catch let error {
            print("Error while parsing screenshot list: \(error)")
            return nil
        }
    }
}

