//
//  Model.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

// MARK: - RecipeModel
struct RecipeModel: Codable {
    var recipes: [Recipe]?
    let total, skip, limit: Int?
}

// MARK: - Recipe
struct Recipe: Codable, Hashable {
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

    init(
        id: Int? = nil,
        name: String? = nil,
        ingredients: [String]? = nil,
        instructions: [String]? = nil,
        prepTimeMinutes: Int? = nil,
        cookTimeMinutes: Int? = nil,
        servings: Int? = nil,
        difficulty: Difficulty? = nil,
        cuisine: String? = nil,
        caloriesPerServing: Int? = nil,
        tags: [String]? = nil,
        userId: Int? = nil,
        image: String? = nil,
        rating: Double? = nil,
        reviewCount: Int? = nil,
        mealType: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTimeMinutes = prepTimeMinutes
        self.cookTimeMinutes = cookTimeMinutes
        self.servings = servings
        self.difficulty = difficulty
        self.cuisine = cuisine
        self.caloriesPerServing = caloriesPerServing
        self.tags = tags
        self.userId = userId
        self.image = image
        self.rating = rating
        self.reviewCount = reviewCount
        self.mealType = mealType
    }

    var displayedTags: [String] {
        guard let tags = self.tags else { return [] }
        if tags.count > 3 {
            return Array(tags.prefix(2)) + ["+\(tags.count - 2) more"]
        } else {
            return tags
        }
    }
}

enum Difficulty: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
}
