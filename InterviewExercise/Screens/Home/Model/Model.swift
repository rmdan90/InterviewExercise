//
//  Model.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/3/25.
//

// MARK: - RecipeModel
struct RecipeModel: Codable {
    let recipes: [Recipe]?
    let total, skip, limit: Int?
}

// MARK: - Recipe
struct Recipe: Codable {
    let id: Int?
    let name: String?
    let ingredients, instructions: [String]?
    let prepTimeMinutes, cookTimeMinutes, servings: Int?
    let difficulty: Difficulty?
    let cuisine: String?
    let caloriesPerServing: Int?
    let tags: [String]?
    let userId: Int?
    let image: String?
    let rating: Double?
    let reviewCount: Int?
    let mealType: [String]?
}

enum Difficulty: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
}
