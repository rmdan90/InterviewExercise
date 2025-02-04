//
//  ErrorAlertModifier.swift
//  InterviewExercise
//
//  Created by ramadan Al on 2/5/25.
//


import SwiftUI

import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    let errorMessage: String?
    @Binding var isPresented: Bool
    let retryAction: () -> Void
    let cancelAction: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                errorMessage ?? "Something went wrong",
                isPresented: $isPresented,
                actions: {
                    Button("Cancel", role: .cancel) {
                        cancelAction()
                        isPresented = false
                    }
                    Button("Retry", role: .destructive) {
                        retryAction()
                        isPresented = false
                    }
                }
            )
    }
}

extension View {
    func errorAlert(
        errorMessage: String?,
        isPresented: Binding<Bool>,
        retryAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            ErrorAlertModifier(
                errorMessage: errorMessage,
                isPresented: isPresented,
                retryAction: retryAction,
                cancelAction: cancelAction
            )
        )
    }
}
