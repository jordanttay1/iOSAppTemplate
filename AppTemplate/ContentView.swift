//
//  ContentView.swift
//  AppTemplate
//
//  Created by Jordan Taylor on 4/21/25.
//

import SwiftUI

struct ContentView: View {
    // Receive the AuthViewModel from the environment
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView { // Add NavigationView for title and toolbar
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                // Display user email if available
                if let email = authViewModel.currentUser?.email {
                    Text("Logged in as: \(email)")
                        .padding(.top)
                } else {
                    Text("Welcome!")
                        .padding(.top)
                }

                Spacer() // Push logout to toolbar
            }
            .padding()
            .navigationTitle("Main Content") // Add a title
            .toolbar { // Add a toolbar for the logout button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log Out") {
                        authViewModel.signOut()
                    }
                }
            }
        }
    }
}

// Update Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a dummy AuthViewModel, potentially simulating a logged-in state
        let previewAuthViewModel = AuthViewModel()
        // previewAuthViewModel.updateUserState(isAuthenticated: true, user: nil) // Example

        ContentView()
            .environmentObject(previewAuthViewModel)
    }
}
