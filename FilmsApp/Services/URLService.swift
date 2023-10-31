//
//  URLService.swift
//  FilmsApp
//
//  Created by Boris Kotov on 10.10.2023.
//

import Foundation
import UIKit

class URLService {
    static let global = URLService()
    static let apiKey = "d92f715947a7df7a64e23f651df3b67a"
    
    static let movieListURL = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\(URLService.apiKey)&language=en-US&page=1")!
    
    let session = URLSession.shared
    
    let parser = JSONParsingService()
    
    var imageCache = NSCache<NSString, UIImage>()
        
    func fetchMovieList(completion: @escaping ([FilmObject]) -> Void) {
        fetchURL(URLService.movieListURL) { data in
            guard let filmObjects = self.parser.parseMovieList(data: data) else { return }
            completion(filmObjects)
        }
    }
    
    func fetchScreenshotList(movieId: Int, completion: @escaping ([Screenshot]) -> Void) {
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)/images?api_key=\(URLService.apiKey)"
        guard let url = URL(string: urlString) else { return }

        fetchURL(url) { data in
            guard let screenshots = self.parser.parseScreenshotList(data: data) else { return }
            completion(screenshots)
        }
    }

    private func fetchURL(_ url: URL, completion: @escaping (Data) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            guard let data,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  error == nil
            else { return }
            completion(data)
        }
        task.resume()
    }
    
    func screenshotURL(filePath: String, format: String) -> URL {
        return URL(string: "https://www.themoviedb.org/t/p/\(format)\(filePath)")!
    }
    
    func fetchImage(url: URL, completion: @escaping (UIImage) -> Void) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
        
        let downloadTask = session.dataTask(with: request) { [weak self] data, response, error in
            guard error == nil,
                  let data,
                  let response = response as? HTTPURLResponse, response.statusCode == 200,
                  let self else {
                return
            }
            
            guard let image = UIImage(data: data) else {
                return
            }
            
            self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        downloadTask.resume()
    }
}
