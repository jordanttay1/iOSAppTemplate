//
//  AppTemplateApp.swift
//  AppTemplate
//
//  Created by Jordan Taylor on 4/21/25.
//

import SwiftUI

@main
struct AppTemplateApp: App {
    // Initialize SupabaseManager early
    init() {
        SupabaseManager.shared.initialize()
    }

    // Create the AuthViewModel as a StateObject
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            // Conditionally show Login or Content view
            if authViewModel.isAuthenticated {
                ContentView()
                    .environmentObject(authViewModel) // Inject into environment
            } else {
                LoginView()
                    .environmentObject(authViewModel) // Inject into environment
            }
        }
    }
}
