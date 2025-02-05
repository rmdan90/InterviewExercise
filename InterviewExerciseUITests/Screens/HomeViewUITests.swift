//
//  HomeViewUITests.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/5/25.
//

import XCTest

import XCTest

final class HomeViewUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    func testHomeView_initialState() {
        let searchBar = app.searchFields["Search"]
        let recipesNavigationTitle = app.navigationBars["Recipes"]

        XCTAssertTrue(searchBar.exists, "Search bar should be visible.")
        XCTAssertTrue(recipesNavigationTitle.exists, "Navigation title should be 'Recipes'.")
    }

    func testHomeView_displaysRecipes() {
        let firstRecipe = app.buttons.firstMatch
        XCTAssertTrue(firstRecipe.waitForExistence(timeout: 5), "Recipes should load and be visible.")
    }

    func testHomeView_searchFunctionality() {
        let searchBar = app.searchFields["Search"]
        searchBar.tap()
        searchBar.typeText("Pasta")

        app.keyboards.buttons["Search"].tap()

        let firstRecipe = app.buttons.firstMatch
        XCTAssertTrue(firstRecipe.waitForExistence(timeout: 5), "Search results should be displayed.")

        searchBar.tap()
        searchBar.typeText("Pasta123123124")
        app.keyboards.buttons["Search"].tap()
        XCTAssertTrue(app.staticTexts["No results found"].waitForExistence(timeout: 5), "No results message should appear when search yields no matches.")
    }

    func testNavigation_toRecipeDetailsView() {
        let firstRecipe = app.buttons.firstMatch
        XCTAssertTrue(firstRecipe.exists, "Recipe card should be visible.")

        firstRecipe.tap()

        let detailsView = app.otherElements.firstMatch
        XCTAssertTrue(detailsView.waitForExistence(timeout: 5), "RecipeDetailsView should be displayed.")

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(firstRecipe.exists, "Should return to HomeView after navigating back.")
    }

    func testHomeView_pullToRefresh() {
        let firstRecipe = app.buttons.firstMatch
        app.swipeDown()

        XCTAssertTrue(firstRecipe.waitForExistence(timeout: 5), "Recipes should reload after pull-to-refresh.")
    }
}
