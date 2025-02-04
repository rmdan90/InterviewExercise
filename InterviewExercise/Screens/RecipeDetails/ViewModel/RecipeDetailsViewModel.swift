//
//  RecipeDetailsViewModel.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

import Foundation

@MainActor
class RecipeDetailsViewModel: ObservableObject {
    @Published var state: State
    private let input: Input
    let dependencies: Dependencies

    init(input: Input, dependencies: Dependencies) {
        self.input = input
        self.dependencies = dependencies
        self.state = .init(recipe: input.recipe)
    }

    func reduce(_ action: Action) {
        switch action {
        case .getRecipeDetails:
            Task { await getRecipesDetails() }
        case .dismissError:
            state.showErrorAlert = false
            state.error = nil
        }
    }

    private func getRecipesDetails() async {
        do {
            let endpoint = RecipesEndpoint.getRecipeDetails(id: state.recipe.id ?? 0)
            let response: Recipe = try await dependencies.networkService.fetch(endpoint: endpoint)

            self.state.recipe = response
        } catch(let error) {
            self.state.showErrorAlert = true
            self.state.error = error.localizedDescription
        }
    }
}

extension RecipeDetailsViewModel {
    class Input {
        let recipe: Recipe

        init(recipe: Recipe) {
            self.recipe = recipe
        }
    }

    struct State {
        var recipe: Recipe
        var error: String?
        var showErrorAlert: Bool = false
    }

    enum Action {
        case getRecipeDetails
        case dismissError
    }

    struct Dependencies {
        let networkService: NetworkService
    }

}
