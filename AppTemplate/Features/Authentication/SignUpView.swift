//
//  SignUpView.swift
//  AppTemplate
//
//  Created by AI Assistant
//

import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    // Add state variables for loading, error handling, etc.
    @State private var isLoading = false // Add state for loading
    @State private var errorMessage: String? // Add state for error messages

    // Add environment variables
    @Environment(\.dismiss) var dismiss // To dismiss the view
    @EnvironmentObject var authViewModel: AuthViewModel // Inject AuthViewModel

    var body: some View {
        ZStack { // Wrap in ZStack for loading indicator
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .padding(.bottom, 40)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disabled(isLoading) // Disable when loading

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .disabled(isLoading) // Disable when loading

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .disabled(isLoading) // Disable when loading
                
                // Display error message if present
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 5)
                }

                Button("Sign Up") {
                    // TODO: Implement sign up logic using SupabaseManager
                    // TODO: Add password confirmation validation
                    // print("Sign Up tapped")
                    signUp()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .disabled(isLoading) // Disable when loading

                Spacer()
                
                Button("Already have an account? Login") {
                    // print("Navigate to Login tapped")
                    // Dismiss the SignUpView to go back to LoginView
                    dismiss()
                }
                .disabled(isLoading) // Disable when loading
            }
            .padding()
            // TODO: Add navigation title, error alerts, etc.
            .navigationTitle("Create Account") // Add a title
            .navigationBarBackButtonHidden(isLoading) // Hide back button while loading

            // Loading Indicator Overlay
            if isLoading {
                Color(.systemBackground).opacity(0.3).ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    // Add a frame to potentially stabilize layout
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }

    private func signUp() {
        // Basic Validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password cannot be empty."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        // Trim whitespace from email just in case
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Email cannot be empty."
            return
        }

        isLoading = true
        errorMessage = nil

        // Log the exact email being sent
        print("Attempting sign up with email: '\(trimmedEmail)'")

        Task {
            do {
                // Use the trimmed email
                let user = try await SupabaseManager.shared.signUpWithEmail(email: trimmedEmail, password: password)
                // Sign up successful - Update the shared AuthViewModel
                print("Sign up successful for user: \(user.email ?? "No email")")
                // Supabase often requires email confirmation, so the user isn't *fully* authenticated yet
                // For simplicity here, we'll treat sign up as immediate login
                authViewModel.updateUserState(isAuthenticated: true, user: user)
                // You might want to dismiss this view explicitly or let the App view handle the state change
            } catch {
                print("Sign up failed: \(error.localizedDescription)")
                errorMessage = "Sign up failed: \(error.localizedDescription)"
                // Optionally update authViewModel error state too
                // authViewModel.setError(message: error.localizedDescription)
            }
            isLoading = false
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView()
                .environmentObject(AuthViewModel()) // Add environment object for preview
        }
    }
} 