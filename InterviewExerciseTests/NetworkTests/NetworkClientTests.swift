//
//  NetworkClientTests.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//


import XCTest
@testable import InterviewExercise

final class NetworkClientTests: XCTestCase {

    private var networkClient: NetworkService!
    private var session: URLSession!

    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
        
        networkClient = NetworkClient(session: session)
    }

    override func tearDown() {
        networkClient = nil
        session = nil
        super.tearDown()
    }

    // MARK: - Success Cases

    func testGetRecipes_Success() async throws {
        let mockJSON = """
        {
           "recipes": [
             { "id": 1, "title": "Recipe 1" },
             { "id": 2, "title": "Recipe 2" }
           ],
           "total": 100
        }
        """
        let mockData = Data(mockJSON.utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            XCTAssertEqual(request.url?.path, "/recipes")
            let query = request.url?.query ?? ""
            XCTAssertTrue(query.contains("limit=5"), "Expected limit=5 query item.")
            
            return (response, mockData)
        }
        
        struct RecipeList: Decodable {
            let recipes: [Recipe]
            let total: Int
        }
        
        struct Recipe: Decodable {
            let id: Int
            let title: String
        }
        
        let endpoint = RecipesEndpoint.getRecipes(limit: 5, skip: 0)
        let result: RecipeList = try await networkClient.fetch(
            endpoint: endpoint
        )

        XCTAssertEqual(result.recipes.count, 2)
        XCTAssertEqual(result.recipes.first?.id, 1)
        XCTAssertEqual(result.recipes.first?.title, "Recipe 1")
        XCTAssertEqual(result.total, 100)
    }

    func testGetRecipeDetails_Success() async throws {
        let mockJSON = """
        {
           "id": 123,
           "title": "Some Recipe"
        }
        """
        let mockData = Data(mockJSON.utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            XCTAssertEqual(request.url?.path, "/recipes/123")

            return (response, mockData)
        }
        
        struct Recipe: Decodable {
            let id: Int
            let title: String
        }
        
        let endpoint = RecipesEndpoint.getRecipeDetails(id: 123)
        let recipe: Recipe = try await networkClient.fetch(endpoint: endpoint)
        
        XCTAssertEqual(recipe.id, 123)
        XCTAssertEqual(recipe.title, "Some Recipe")
    }

    // MARK: - Error Cases

    func testFetch_NotFoundError() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        do {
            let endpoint = RecipesEndpoint.getRecipeDetails(id: 9999)
            let _: TestResponseModel = try await networkClient.fetch(
                endpoint: endpoint
            )
            XCTFail("Expected an error for 404, but call succeeded.")
        } catch let error as NetworkError {
            switch error {
            case .requestFailed(let statusCode):
                XCTAssertEqual(statusCode, 404, "Expected 404, got \(statusCode)")
            default:
                XCTFail("Expected a requestFailed(404) error, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetch_ServerError() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        do {
            let endpoint = RecipesEndpoint.getRecipes(limit: 10, skip: 0)
            let _: TestResponseModel = try await networkClient.fetch(
                endpoint: endpoint
            )
            XCTFail("Expected a 500 error, but call succeeded.")
        } catch let error as NetworkError {
            switch error {
            case .requestFailed(let statusCode):
                XCTAssertEqual(statusCode, 500)
            default:
                XCTFail("Expected .requestFailed(500), got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetch_DecodingFailure() async {
        let invalidJSON = """
        {
            "someRandomKey": "Not expected here"
        }
        """
        let invalidData = Data(invalidJSON.utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidData)
        }
        
        struct Recipe: Decodable {
            let id: Int
            let title: String
        }
        
        do {
            let endpoint = RecipesEndpoint.getRecipes(limit: 1, skip: 0)
            let _: Recipe = try await networkClient.fetch(endpoint: endpoint)
            XCTFail("Expected a decoding error, but call succeeded.")
        } catch let error as NetworkError {
            switch error {
            case .decodingFailed:
                //Success
                break
            default:
                XCTFail("Expected .decodingFailed, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetch_UnknownError() async {
        MockURLProtocol.requestHandler = { request in
            throw URLError(.notConnectedToInternet)
        }
        
        do {
            let endpoint = RecipesEndpoint.getRecipes(limit: 5, skip: 0)
            let _: TestResponseModel = try await networkClient.fetch(endpoint: endpoint)
            XCTFail("Expected an unknown error (URLError), but call succeeded.")
        } catch let error as NetworkError {
            switch error {
            case .unknown(let underlyingError):
                // This is the expected path for URLError
                XCTAssertTrue(underlyingError is URLError, "Expected URLError, got \(type(of: underlyingError))")
            default:
                XCTFail("Expected .unknown(URLError), got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetch_InvalidURL() async {
        struct BadEndpoint: Endpoint {
            var baseURL: URL { return URL(string: " ")! }
            var path: String = ""
            var method: HTTPMethod = .get
            var headers: [String : String]? = nil
            var body: Encodable? = nil
            var queryItems: [URLQueryItem]? = nil
        }
        
        do {
            let _: TestResponseModel = try await networkClient.fetch(endpoint: BadEndpoint())
            XCTFail("Expected an invalidURL error, but succeeded.")
        } catch let error as NetworkError {
            switch error {
            case .invalidURL:
                break
            default:
                XCTFail("Expected .invalidURL, but got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    //MARK: Helpers
    struct TestResponseModel: Decodable {
        let message: String
    }
}
