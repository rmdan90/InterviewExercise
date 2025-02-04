//
//  RecipesEndpoint.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

import Foundation

enum RecipesEndpoint: Endpoint {
    case getRecipes(limit: Int, skip: Int)
    case searchRecipes(query: String)
    case getRecipeDetails(id: Int)

    var baseURL: URL {
        return URL(string: "https://dummyjson.com")!
    }

    var path: String {
        switch self {
        case .getRecipes:
            return "/recipes"
        case .searchRecipes:
            return "/recipes/search"
        case .getRecipeDetails(let id):
            return "/recipes/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getRecipes, .getRecipeDetails, .searchRecipes:
            return .get
        }
    }

    var headers: [String: String]? {
        switch self {
        case .getRecipes, .getRecipeDetails, .searchRecipes:
            return nil
        }
    }

    var body: Encodable? {
        switch self {
        case .getRecipes, .getRecipeDetails, .searchRecipes:
            return nil
        }
    }

    /// Provide a limit for paginated requests
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getRecipes(let limit, let skip):
            return [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "skip", value: "\(skip)")
            ]
        case .searchRecipes(let query):
            return [URLQueryItem(name: "q", value: query)]
        case .getRecipeDetails:
            return nil
        }
    }
}
