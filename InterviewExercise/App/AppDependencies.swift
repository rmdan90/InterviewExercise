//
//  AppDependencies.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

import Foundation

final class AppDependencies: ObservableObject {
    let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }
}
