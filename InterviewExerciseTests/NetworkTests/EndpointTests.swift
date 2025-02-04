//
//  NetworkClientHeadersAndBodyTests.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

import XCTest
@testable import InterviewExercise

class EndpointTests: XCTestCase {

    // MARK: - URL Construction Tests

    func testURLConstructionWithBaseURLAndPath() throws {
        let baseURL = URL(string: "https://example.com")!
        let endpoint = MockEndpoint(
            baseURL: baseURL,
            path: "/api/test",
            method: .get,
            headers: nil,
            body: nil,
            queryItems: nil
        )

        let request = try endpoint.asURLRequest()

        XCTAssertEqual(request.url?.absoluteString, "https://example.com/api/test")
    }

    func testURLConstructionWithQueryItems() throws {
        let baseURL = URL(string: "https://example.com")!
        let queryItems = [URLQueryItem(name: "search", value: "term")]
        let endpoint = MockEndpoint(
            baseURL: baseURL,
            path: "/search",
            method: .get,
            headers: nil,
            body: nil,
            queryItems: queryItems
        )

        let request = try endpoint.asURLRequest()

        XCTAssertEqual(request.url?.query, "search=term")
    }

    // MARK: - HTTP Method Tests

    func testHTTPMethodSetCorrectly() throws {
        let baseURL = URL(string: "https://example.com")!
        let endpoint = MockEndpoint(
            baseURL: baseURL,
            path: "",
            method: .post,
            headers: nil,
            body: nil,
            queryItems: nil
        )

        let request = try endpoint.asURLRequest()

        XCTAssertEqual(request.httpMethod, "POST")
    }

    // MARK: - Header Tests

    func testHeadersAreAdded() throws {
        let baseURL = URL(string: "https://example.com")!
        let headers = ["Authorization": "Bearer token"]
        let endpoint = MockEndpoint(
            baseURL: baseURL,
            path: "",
            method: .get,
            headers: headers,
            body: nil,
            queryItems: nil
        )

        let request = try endpoint.asURLRequest()

        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token")
    }

    // MARK: - Body Tests

    func testJSONBodyIsEncoded() throws {
        struct TestBody: Codable {
            let key: String
        }
        let body = TestBody(key: "value")
        let baseURL = URL(string: "https://example.com")!
        let endpoint = MockEndpoint(
            baseURL: baseURL,
            path: "",
            method: .post,
            headers: nil,
            body: body,
            queryItems: nil
        )

        let request = try endpoint.asURLRequest()
        let decodedBody = try JSONDecoder().decode(TestBody.self, from: request.httpBody!)

        XCTAssertEqual(decodedBody.key, "value")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    // MARK: - Error Handling Tests

    func testInvalidBaseURLThrowsError() {
        let invalidBaseURL = URL(string: "invalid://")! // Scheme is present but host is missing
        let endpoint = MockEndpoint(
            baseURL: invalidBaseURL,
            path: "",
            method: .get,
            headers: nil,
            body: nil,
            queryItems: nil
        )

        XCTAssertThrowsError(try endpoint.asURLRequest()) { error in
            XCTAssertEqual(error as? NetworkError, NetworkError.invalidURL)
        }
    }
}

// MARK: - Mock Endpoint Implementation

private struct MockEndpoint: Endpoint {
    var baseURL: URL
    var path: String
    var method: HTTPMethod
    var headers: [String: String]?
    var body: Encodable?
    var queryItems: [URLQueryItem]?
}

extension NetworkError: @retroactive Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        default:
            return false
        }
    }
}
