//
//  UITests.swift
//  FilmsAppUITests
//
//  Created by Boris Kotov on 31.10.2023.
//

import XCTest

final class UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialLoad() throws {
        let app = XCUIApplication()
        app.launch()

        let cell = app.collectionViews["MainCollection"].cells.containing(.cell, identifier: "FilmCell").firstMatch
        cell.waitForExistence(timeout: 10)
    }
    
    func testDetailView() throws {
        let app = XCUIApplication()
        app.launch()

        let cell = app.collectionViews["MainCollection"].cells.containing(.cell, identifier: "FilmCell").firstMatch
        cell.waitForExistence(timeout: 10)

        let title = cell.staticTexts["CellFilmTitleLabel"].label
        let year = cell.staticTexts["CellReleaseYearLabel"].label
        let rating = cell.staticTexts["CellRatingLabel"].label
        
        cell.tap()
        
        let detailView = app.otherElements["DetailView"].firstMatch
        
        detailView.waitForExistence(timeout: 5)
        
        let detailTitle = detailView.staticTexts["DetailFilmTitleLabel"].label
        let detailYear = detailView.staticTexts["DetailReleaseYearLabel"].label
        let detailRating = detailView.staticTexts["DetailRatingLabel"].label
        
        XCTAssertEqual(title, detailTitle, "Title in the detailed view doesn't match the main screen")
        XCTAssertEqual(year, detailYear, "Release year in the detailed view doesn't match the main screen")
        XCTAssertEqual(rating, detailRating, "Rating in the detailed view doesn't match the main screen")
    }
}
