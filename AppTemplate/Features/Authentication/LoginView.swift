//
//  LoginView.swift
//  AppTemplate
//
//  Created by AI Assistant
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(5.0)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disabled(isLoading)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .disabled(isLoading)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.bottom, 5)
                    }

                    Button("Login") {
                        login()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)

                    Spacer()

                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Sign Up")
                    }
                    .padding(.top, 10)
                    .disabled(isLoading)

                }
                .padding()
                .navigationTitle("Login")

                if isLoading {
                    Color(.systemBackground).opacity(0.3).ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let user = try await SupabaseManager.shared.signInWithEmail(email: email, password: password)
                print("Login successful for user: \(user.email ?? "No email")")
                authViewModel.updateUserState(isAuthenticated: true, user: user)
            } catch {
                print("Login failed: \(error.localizedDescription)")
                errorMessage = "Login failed: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
} 