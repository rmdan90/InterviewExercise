//
//  NetworkClientHeadersAndBodyTests.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

import XCTest
@testable import InterviewExercise

final class NetworkClientHeadersAndBodyTests: XCTestCase {

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
    
    func testRequestHeadersAndBody() async throws {
        let responseBody = """
        {
          "success": true
        }
        """
        let responseData = responseBody.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-Custom-Header"), "CustomValue")

            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            
            guard let httpBody = request.httpBody else {
                XCTFail("Request body should not be nil.")
                return (HTTPURLResponse(), Data())
            }
            
            do {
                let decodedPayload = try JSONDecoder().decode(TestBody.self, from: httpBody)
                XCTAssertEqual(decodedPayload.name, "Test")
                XCTAssertEqual(decodedPayload.count, 42)
            } catch {
                XCTFail("Failed to decode request body: \(error)")
            }
            
            let url = request.url ?? URL(string: "https://dummyjson.com")!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        let endpoint = TestEndpointWithBody.createTest
        
        struct ResponseModel: Decodable {
            let success: Bool
        }
        
        let response: ResponseModel = try await networkClient.fetch(endpoint: endpoint)
        
        XCTAssertTrue(response.success)
    }
}

struct TestBody: Codable {
    let name: String
    let count: Int
}

enum TestEndpointWithBody: Endpoint {

    case createTest

    var baseURL: URL {
        return URL(string: "https://dummyjson.com")!
    }

    var path: String {
        switch self {
        case .createTest:
            return "/test"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createTest:
            return .post
        }
    }

    var headers: [String : String]? {
        switch self {
        case .createTest:
            return ["X-Custom-Header": "CustomValue"]
        }
    }

    var body: Encodable? {
        switch self {
        case .createTest:
            return TestBody(name: "Test", count: 42)
        }
    }

    var queryItems: [URLQueryItem]? {
        return nil
    }
}
