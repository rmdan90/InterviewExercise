//
//  RecipeCardView.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

import SwiftUI
import Kingfisher

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        ZStack(alignment: .bottom) {
            KFImage.url(URL(string: recipe.image ?? ""))
                .loadDiskFileSynchronously()
                .fade(duration: 0.25)
                .resizable()
                .aspectRatio(contentMode: .fill)

            Text(recipe.name ?? "")
                .foregroundStyle(.white)
                .font(.system(.title3))
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                .black.opacity(0.6),
                                .clear
                            ]
                        ),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
        }
        .overlay(alignment: .topTrailing) {
            HStack {
                ForEach(recipe.displayedTags, id: \.self) { tag in
                    Text(tag)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.8))
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
