//
//  RecipeDetailsViewModelTests.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/5/25.
//

import XCTest
import Combine
@testable import InterviewExercise

@MainActor
final class RecipeDetailsViewModelTests: XCTestCase {

    private var sut: RecipeDetailsViewModel!
    private var mockNetworkService: DetailsMockNetworkService!
    private var cancellables: Set<AnyCancellable> = []
    private var testRecipe: Recipe!

    override func setUp() async throws {
        try await super.setUp()
        mockNetworkService = DetailsMockNetworkService()
        testRecipe = Recipe(id: 1, name: "Test Recipe")

        await MainActor.run {
            let input = RecipeDetailsViewModel.Input(recipe: testRecipe)
            let dependencies = RecipeDetailsViewModel.Dependencies(networkService: mockNetworkService)
            sut = RecipeDetailsViewModel(input: input, dependencies: dependencies)
        }
    }

    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        testRecipe = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Test: Initial State

    func test_initialState() {
        XCTAssertEqual(sut.state.recipe.name, "Test Recipe", "Initial recipe should be set correctly.")
        XCTAssertNil(sut.state.error, "There should be no error initially.")
        XCTAssertFalse(sut.state.showErrorAlert, "showErrorAlert should be false initially.")
    }

    // MARK: - Test: getRecipeDetails

    func test_getRecipeDetails_success() async {
        let updatedRecipe = Recipe(id: 1, name: "Updated Recipe")
        mockNetworkService.mockResponse = updatedRecipe

        sut.reduce(.getRecipeDetails)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.state.recipe.name, "Updated Recipe", "Recipe should be updated after a successful API call.")
        XCTAssertNil(sut.state.error, "Error should be nil after a successful call.")
        XCTAssertFalse(sut.state.showErrorAlert, "Error alert should not be shown.")
    }

    func test_getRecipeDetails_failure() async {
        mockNetworkService.shouldThrowError = true

        sut.reduce(.getRecipeDetails)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(sut.state.showErrorAlert, "Error alert should be shown on failure.")
        XCTAssertNotNil(sut.state.error, "Error message should be set.")
    }

    // MARK: - Test: dismissError

    func test_dismissError() {
        sut.state.error = "Test Error"
        sut.state.showErrorAlert = true

        sut.reduce(.dismissError)

        XCTAssertNil(sut.state.error, "Error should be cleared after dismissing.")
        XCTAssertFalse(sut.state.showErrorAlert, "Error alert should be dismissed.")
    }
}

// MARK: - MockNetworkService

class DetailsMockNetworkService: NetworkService {
    var mockResponse: Recipe?
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
