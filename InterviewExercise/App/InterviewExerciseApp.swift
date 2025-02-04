//
//  InterviewExerciseApp.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/4/25.
//

import SwiftUI

@main
struct InterviewExerciseApp: App {
    @StateObject private var appDependencies = AppDependencies(networkService: NetworkClient())

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView(
                    viewModel: HomeViewModel(
                        dependencies: HomeViewModel
                            .Dependencies(
                                networkService: appDependencies.networkService
                            )
                    )
                )
            }
            .environmentObject(appDependencies)
        }
    }
}
