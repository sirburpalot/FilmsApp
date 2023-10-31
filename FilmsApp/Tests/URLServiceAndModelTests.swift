//
//  URLServiceAndModel.swift
//  FilmsAppTests
//
//  Created by Boris Kotov on 31.10.2023.
//

import XCTest
@testable import FilmsApp

final class URLServiceAndModel: XCTestCase {
    let model = Model(realmConfig: .init(inMemoryIdentifier: "FilmsAppTest"))
    let service = URLService.global

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchMovieList() throws {
        let expectation = expectation(description: "movie list fetched")
        
        service.fetchMovieList { filmObjects in
            if !filmObjects.isEmpty {
                print("Successfully fetched \(filmObjects.count) objects")
            } else {
                XCTFail("Fetched 0 objects")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }

    func testFetchImage() throws {
        let expectation = expectation(description: "image fetched")
        
        service.fetchImage(url: service.screenshotURL(filePath: "/oAgmTEQSCAXpwE16VoRVDGKrykR.jpg",
                                                      format: "w200")) { image in
            print("Successfully fetched an image")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testLoadMovieList() throws {
        let threadComplete = expectation(description: "background thread complete")
        
        var countFetched: Int = 0
        
        service.fetchMovieList { filmObjects in
            countFetched = filmObjects.count
            print("Successfully fetched \(countFetched) objects")
            
            self.model.loadFilms(filmObjects)
            threadComplete.fulfill()
        }
        
        wait(for: [threadComplete], timeout: 10)
        
        let countLoaded = model.filmObjects.count
        print("Loaded \(countLoaded) objects")
        
        if countFetched == countLoaded {
            print("Success! \(countLoaded)/\(countFetched) objects loaded.")
        } else {
            XCTFail("Only \(countLoaded)/\(countFetched) objects loaded.")
        }
    }
    
    func testScreenshotDownload() throws {
        try testLoadMovieList()

        let threadComplete = expectation(description: "background thread complete")
        
        guard let object = self.model.filmObjects.first else {
            XCTFail("No film object in Realm")
            return
        }

        let id = object.id
        
        service.fetchScreenshotList(movieId: id) { screenshots in
            guard !screenshots.isEmpty else {
                XCTFail("Screenshot list is empty")
                threadComplete.fulfill()
                return
            }
            
            let screenshot = screenshots[0]
            let url = self.service.screenshotURL(filePath: screenshot.filePath, format: "w200")
            
            self.service.fetchImage(url: url) { _ in
                print("Successfully fetched a screenshot")
                threadComplete.fulfill()
            }
        }
        
        wait(for: [threadComplete], timeout: 10)
    }
    
    func testToggleLike() throws {
        try testLoadMovieList()
        
        guard let object = self.model.filmObjects.first else {
            XCTFail("No film object in Realm")
            return
        }

        let oldState = object.isLiked
        
        model.updateLike(id: object.id)
        
        let newState = object.isLiked
        
        guard oldState != newState else {
            XCTFail("Old state is the same as new state")
            return
        }
        
        model.showLikedFilms()
        
        if model.likedFilmObjects.first(where: { $0.id == object.id }) == nil {
            XCTFail("Liked object is not in the likedFilmObjects array")
        }
    }
}
