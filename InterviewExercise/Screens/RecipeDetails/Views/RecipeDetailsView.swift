//
//  RecipeDetailsView.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

import SwiftUI
import Kingfisher

struct RecipeDetailsView: View {
    @StateObject var viewModel: RecipeDetailsViewModel
    @State private var selectedTab = 0

    init(viewModel: RecipeDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            KFImage.url(URL(string: viewModel.state.recipe.image ?? ""))
                .loadDiskFileSynchronously()
                .fade(duration: 0.25)
                .resizable()
                .frame(maxHeight: 400)

            ScrollView {
                Picker("Select", selection: $selectedTab) {
                    Text("Ingredients").tag(0)
                    Text("Instructions").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Group {
                    if selectedTab == 0 {
                        ForEach(
                            viewModel.state.recipe.ingredients ?? [],
                            id: \.self
                        ) { ingredient in
                            HStack(alignment: .top) {
                                Text("• \(ingredient)")
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    } else {
                        ForEach(
                            (viewModel.state.recipe.instructions ?? []).indices,
                            id: \.self
                        ) { index in
                            HStack(alignment: .top) {
                                Text("\(index + 1).").bold()
                                Text(viewModel.state.recipe.instructions?[index] ?? "")
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                Spacer()
            }
            .refreshable {
                viewModel.reduce(.getRecipeDetails)
            }
            .errorAlert(
                errorMessage: viewModel.state.error ?? "Something went wrong",
                isPresented: $viewModel.state.showErrorAlert,
                retryAction: {
                    viewModel.reduce(.dismissError)
                    viewModel.reduce(.getRecipeDetails)
                },
                cancelAction: {
                    viewModel.reduce(.dismissError)
                }
            )
        }
        .navigationTitle(viewModel.state.recipe.name ?? "")
    }
}
