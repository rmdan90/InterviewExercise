//
//  ContentView.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @Namespace var namespace

    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            if viewModel.state.shouldShowSearchResults && (viewModel.state.searchResults?.recipes?.isEmpty ?? true) {
                Text("No results found")
            }

            if viewModel.state.isLoading {
                ProgressView()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(
                            viewModel.state.shouldShowSearchResults ?
                            viewModel.state.searchResults?.recipes ?? [] : viewModel.state.recipeModel?.recipes ?? [],
                            id: \.self
                        ) { recipe in
                            NavigationLink(value: recipe) {
                                RecipeCardView(recipe: recipe)
                                    .matchedTransitionSource(
                                        id: recipe.id,
                                        in: namespace
                                    )
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .onScrollTargetVisibilityChange(idType: Recipe.self) { ids in
                    viewModel.reduce(.loadNextRecipes(ids: ids))
                }
            }
        }
        .padding()
        .scrollClipDisabled()
        .onAppear {
            viewModel.reduce(.getRecipes)
        }
        .alert(
            viewModel.state.error ?? "Something went wrong",
            isPresented: $viewModel.state.showErrorAlert,
            actions: {
                Button("Cancel", role: .cancel) {
                    viewModel.reduce(.dismissError)
                }
                Button("Retry", role: .destructive) {
                    viewModel.reduce(.dismissError)
                    viewModel.reduce(.getRecipes)
                }
            }
        )
        .refreshable {
            withAnimation {
                viewModel.reduce(.getRecipes)
            }
        }
        .searchable(text: $viewModel.state.query)
        .onSubmit(of: .search) {
            viewModel.reduce(.searchRecipes)
        }
        .onChange(of: viewModel.state.query) { _, _ in
            if viewModel.state.query.isEmpty {
                viewModel.reduce(.dismissSearch)
            }
        }
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailsView(recipe: recipe)
                .navigationTransition(.zoom(sourceID: recipe.id, in: namespace))

        }
    }
}

#Preview {
    HomeView(
        viewModel: .init(
            dependencies: .init(networkService: NetworkClient())
        )
    )
}
