//
//  JSONModel.swift
//  FilmsApp
//
//  Created by Boris Kotov on 14.08.2023.
//

import Foundation

struct MovieList: Decodable {
    var page: Int
    var results: [FilmObject]
    var totalPages: Int
    var totalResults: Int
    
    private enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct ScreenshotList: Decodable {
    var backdrops: [Screenshot]
}

struct Screenshot: Decodable {
    var aspectRatio: Double
    var height: Int
    var filePath: String
    var voteAverage: Double
    var voteCount: Int
    var width: Int
    
    private enum CodingKeys: String, CodingKey {
        case width, height
        case aspectRatio = "aspect_ratio"
        case filePath = "file_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
