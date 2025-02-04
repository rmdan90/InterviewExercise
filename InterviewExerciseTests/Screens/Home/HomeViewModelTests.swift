//
//  HomeViewModelTests.swift
//  InterviewExercise
//
//  Created by Ramadan Al on 2/4/25.
//

import XCTest
import Combine
@testable import InterviewExercise

@MainActor
final class HomeViewModelTests: XCTestCase {

    private var sut: HomeViewModel!
    private var mockNetworkService: MockNetworkService!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() async throws {
        try await super.setUp()
        mockNetworkService = MockNetworkService()

        await MainActor.run {
            let dependencies = HomeViewModel.Dependencies(networkService: mockNetworkService)
            sut = HomeViewModel(dependencies: dependencies)
        }
    }

    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Test: Initial State

    func test_initialState() {
        XCTAssertTrue(sut.state.isLoading, "isLoading should be true.")
        XCTAssertNil(sut.state.recipeModel, "recipeModel should be nil.")
        XCTAssertNil(sut.state.error, "there should be no error.")
        XCTAssertFalse(sut.state.showErrorAlert, "showErrorAlert should be false.")
        XCTAssertTrue(sut.state.query.isEmpty, "Query should be empty.")
        XCTAssertNil(sut.state.searchResults, "Search results should be nil.")
    }

    // MARK: - Test: getRecipes

    func test_getRecipes_success() async {
        let mockResponse = RecipeModel(
            recipes: [Recipe(id: 1, name: "Recipe 1")],
            total: 20,
            skip: 0,
            limit: 10
        )
        mockNetworkService.mockResponse = mockResponse

        sut.reduce(.getRecipes)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNotNil(sut.state.recipeModel)
        XCTAssertEqual(sut.state.recipeModel?.recipes?.count, 1)
        XCTAssertEqual(sut.state.recipeModel?.total, 20)
        XCTAssertEqual(sut.state.recipeModel?.skip, 0)
        XCTAssertEqual(sut.state.recipeModel?.limit, 10)
        XCTAssertFalse(sut.state.isLoading)
    }

    func test_getRecipes_failure() async {
        mockNetworkService.shouldThrowError = true

        sut.reduce(.getRecipes)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNil(sut.state.recipeModel, "Recipe model should be nil on failure.")
        XCTAssertTrue(sut.state.showErrorAlert, "Error alert should be shown on failure.")
        XCTAssertTrue(sut.state.error?.contains("TestError") ?? false, "Expected error message to contain 'TestError'")
    }

    // MARK: - Test: loadNextRecipes
    func test_loadNextRecipes_success() async {
        let initialRecipes = RecipeModel(
            recipes: [Recipe(id: 1, name: "Burger")],
            total: 4,
            skip: 0,
            limit: 2
        )
        sut.state.recipeModel = initialRecipes

        let additionalRecipes = RecipeModel(
            recipes: [Recipe(id: 2, name: "Salad")],
            total: 4,
            skip: 2,
            limit: 2
        )
        mockNetworkService.mockResponse = additionalRecipes

        sut.reduce(.loadNextRecipes(ids: [Recipe(id: 1, name: "Burger")]))
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.state.recipeModel?.recipes?.count, 2)
        XCTAssertEqual(sut.state.recipeModel?.recipes?.last?.name, "Salad")
    }

    func test_loadNextRecipes_noNewData() async {
        let initialRecipes = RecipeModel(
            recipes: [Recipe(id: 1, name: "Burger"), Recipe(id: 2, name: "Salad")],
            total: 2,
            skip: 0,
            limit: 2
        )
        sut.state.recipeModel = initialRecipes

        sut.reduce(.loadNextRecipes(ids: [Recipe(id: 2, name: "Salad")]))
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.state.recipeModel?.recipes?.count, 2, "No new recipes should be added.")
    }

    // MARK: - Test: dismissError

    func test_dismissError() {
        sut.state.error = "TestError"
        sut.state.showErrorAlert = true

        sut.reduce(.dismissError)

        XCTAssertNil(sut.state.error, "Error should be cleared.")
        XCTAssertFalse(sut.state.showErrorAlert, "Error alert should be dismissed.")
    }

    // MARK: - Test: retry

    func test_retry_afterFailure() async {
        mockNetworkService.shouldThrowError = true
        sut.reduce(.getRecipes)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNotNil(sut.state.error, "Error should be set on failure.")

        let mockResponse = RecipeModel(
            recipes: [Recipe(id: 10, name: "Retry Meal")],
            total: 1,
            skip: 0,
            limit: 1
        )
        mockNetworkService.shouldThrowError = false
        mockNetworkService.mockResponse = mockResponse

        sut.reduce(.retry)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNotNil(sut.state.recipeModel)
        XCTAssertEqual(sut.state.recipeModel?.recipes?.first?.name, "Retry Meal")
        XCTAssertNil(sut.state.error, "Error should be cleared after a successful retry.")
        XCTAssertFalse(sut.state.showErrorAlert, "No error alert should be shown after a successful retry.")
    }

    // MARK: - Test: seacrh

    func test_searchRecipes_success() async {
        sut.state.query = "Pasta"
        let mockResponse = RecipeModel(
            recipes: [Recipe(id: 10, name: "Pasta")],
            total: 1,
            skip: 0,
            limit: 10
        )
        mockNetworkService.mockResponse = mockResponse

        sut.reduce(.searchRecipes)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(sut.state.searchResults, "Search results should not be nil")
        XCTAssertEqual(sut.state.searchResults?.recipes?.first?.name, "Pasta")
        XCTAssertFalse(sut.state.isLoading, "isLoading should be false after search")
    }

    func test_searchRecipes_failure() async {
        sut.state.query = "Pasta"
        mockNetworkService.shouldThrowError = true

        sut.reduce(.searchRecipes)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(sut.state.showErrorAlert, "Error alert should be shown")
        XCTAssertNotNil(sut.state.error, "Error message should be set")
        XCTAssertNil(sut.state.searchResults, "Search results should be nil on failure")
    }

    func test_dismissSearch() {
        sut.state.query = "Pizza"
        sut.state.searchResults = RecipeModel(
            recipes: [Recipe(id: 1, name: "Pizza")],
            total: 1,
            skip: 0,
            limit: 1
        )

        sut.reduce(.dismissSearch)

        XCTAssertNil(sut.state.searchResults, "Search results should be cleared after dismissSearch.")
    }
}

// MARK: - MockNetworkService

class MockNetworkService: NetworkService {
    var mockResponse: RecipeModel?
    var shouldThrowError = false

    func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 0, userInfo: nil)
        }
        if let mockResponse = mockResponse as? T {
            return mockResponse
        }
        throw NSError(domain: "InvalidMock", code: 0, userInfo: nil)
    }
}
