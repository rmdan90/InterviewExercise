//
//  HomeViewModel.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var state: State
    let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.state = .init()
    }

    func reduce(_ action: Action) {
        print("Received action: \(action)")
        switch action {
        case .getRecipes:
            Task { await getRecipes() }
        case .loadNextRecipes(let ids):
            if let lastRecipe = state.recipeModel?.recipes?.last,
               !state.shouldShowSearchResults,
               ids.contains(where: { $0.id == lastRecipe.id }),
               canLoadMoreRecipes() {
                Task { await getRecipes(skip: state.loadedRecipesCount) }
            }
        case .dismissError:
            state.error = nil
            state.showErrorAlert = false
        case .retry:
            state.error = nil
            state.showErrorAlert = false
            Task { await getRecipes() }
        case .searchRecipes:
            Task { await searchRecipes() }
        case .dismissSearch:
            state.searchResults = nil
        }
    }

    private func getRecipes(skip: Int = 0, limit: Int = 10) async {
        if skip == 0 {
            self.state.isLoading = true
        }
        do {
            let endpoint = RecipesEndpoint.getRecipes(limit: 10, skip: skip)
            let response: RecipeModel = try await dependencies.networkService.fetch(endpoint: endpoint)

            if skip == 0 {
                self.state.recipeModel = response
            } else {
                if let existing = self.state.recipeModel {
                    var updated = existing
                    updated.recipes?.append(contentsOf: response.recipes ?? [])
                    self.state.recipeModel = updated
                } else {
                    self.state.recipeModel = response
                }
            }
            self.state.isLoading = false
        } catch(let error) {
            self.state.isLoading = false
            self.state.showErrorAlert = true
            self.state.error = error.localizedDescription
        }
    }

    private func searchRecipes() async {
        self.state.isLoading = true
        do {
            let endpoint = RecipesEndpoint.searchRecipes(query: state.query)
            let response: RecipeModel = try await dependencies.networkService.fetch(
                endpoint: endpoint
            )
            self.state.searchResults = response
            self.state.isLoading = false
        } catch(let error) {
            self.state.isLoading = false
            self.state.showErrorAlert = true
            self.state.error = error.localizedDescription
        }
    }

    private func canLoadMoreRecipes() -> Bool {
        return state.loadedRecipesCount < (state.recipeModel?.total ?? 0)
    }
}

extension HomeViewModel {
    struct State {
        var recipeModel: RecipeModel?
        var isLoading: Bool = true
        var error: String?
        var showErrorAlert: Bool = false
        var query: String = ""
        var searchResults: RecipeModel?
        var shouldShowSearchResults: Bool {
            !query.isEmpty && (searchResults != nil)
        }
        var loadedRecipesCount: Int {
            recipeModel?.recipes?.count ?? 0
        }
    }

    enum Action {
        case getRecipes
        case loadNextRecipes(ids: [Recipe])
        case dismissError
        case retry
        case searchRecipes
        case dismissSearch
    }

    struct Dependencies {
        let networkService: NetworkService
    }
}
