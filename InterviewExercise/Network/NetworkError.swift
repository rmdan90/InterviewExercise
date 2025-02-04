//
//  NetworkError.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed(Error)
    case unknown(Error)
}
