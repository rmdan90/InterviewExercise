//
//  NetworkClient.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

import Foundation

final class NetworkClient: NetworkService {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T {
        let request: URLRequest
        do {
            request = try endpoint.asURLRequest()
        } catch {
            throw error
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            if let urlError = error as? URLError {
                throw NetworkError.unknown(urlError)
            } else {
                throw NetworkError.unknown(error)
            }
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(URLError(.badServerResponse))
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        }

        #if DEBUG
        print(String(decoding: data, as: UTF8.self))
        #endif
        do {
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            return decodedObject
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
