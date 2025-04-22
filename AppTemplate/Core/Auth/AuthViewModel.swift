//
//  AuthViewModel.swift
//  AppTemplate
//
//  Created by AI Assistant
//

import SwiftUI
import Combine // Needed for ObservableObject
import Supabase // Needed for User type

@MainActor // Ensure UI updates happen on the main thread
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = true // Start loading initially
    @Published var errorMessage: String? = nil

    private var initialLoadComplete = false // Flag to prevent race conditions

    init() {
        print("AuthViewModel: Initializing...")
        // 1. Attempt to load session synchronously from Keychain
        if let (accessToken, refreshToken) = KeychainHelper.loadSession() {
            print("AuthViewModel: Found session in Keychain.")
            // 2. Try to set the session in the Supabase client
            Task {
                do {
                    // *** Check Supabase Docs: This is the assumed method ***
                    // If this method doesn't exist or works differently, this needs adjustment.
                    let session = try await SupabaseManager.shared.client.auth.setSession(accessToken: accessToken, refreshToken: refreshToken)
                    print("AuthViewModel: Supabase client session set from Keychain.")
                    // Successfully set session, update state synchronously if possible
                    // Note: setSession might implicitly trigger auth state changes in newer Supabase versions
                    self.isAuthenticated = true
                    self.currentUser = session.user // User might be available immediately
                    self.errorMessage = nil
                    self.initialLoadComplete = true
                    // 3. Proceed to validate the session with Supabase
                    await validateSessionOrConfirmLogout(isResuming: true)
                } catch {
                    print("AuthViewModel: Failed to set Supabase client session from Keychain: \(error.localizedDescription). Clearing Keychain.")
                    // Failed to use the stored tokens (likely expired/invalid)
                    _ = KeychainHelper.deleteSession()
                    self.isAuthenticated = false
                    self.currentUser = nil
                    self.initialLoadComplete = true
                    // Proceed to confirm logged out state
                    await validateSessionOrConfirmLogout(isResuming: false)
                }
            }
        } else {
            print("AuthViewModel: No session found in Keychain.")
            // No session found, proceed to confirm logged out state
            self.isAuthenticated = false
            self.currentUser = nil
            self.initialLoadComplete = true
            Task { // Run validation asynchronously
                 await validateSessionOrConfirmLogout(isResuming: false)
            }
        }
    }

    // Renamed and adjusted logic
    private func validateSessionOrConfirmLogout(isResuming: Bool) async {
        // Only run validation if initial Keychain load is done
        guard initialLoadComplete else { 
            print("AuthViewModel: Validation skipped, initial load not complete.")
            isLoading = false // Ensure loading stops if skipped
            return 
        }
        print("AuthViewModel: Validating session with Supabase (isResuming: \(isResuming))...")
        isLoading = true // Show loading during validation
        // Don't clear error message here if resuming, might be from setSession failure
        // errorMessage = nil

        do {
            // Use getSession which might attempt refresh if needed
            let session = try await SupabaseManager.shared.client.auth.session
            // If we get here, the session is valid (potentially refreshed)
            print("AuthViewModel: Session validated successfully. User: \(session.user.email ?? "No Email")")
            self.currentUser = session.user
            self.isAuthenticated = true // Ensure state is correct
            self.errorMessage = nil // Clear any previous errors
            // Re-save the potentially refreshed tokens
            if let currentSession = try? await SupabaseManager.shared.client.auth.session {
                _ = KeychainHelper.saveSession(accessToken: currentSession.accessToken, refreshToken: currentSession.refreshToken)
            }
        } catch {
            // Error getting/refreshing session
            print("AuthViewModel: Session validation failed or user not logged in. Error: \(error.localizedDescription)")
            // Clear user state and Keychain only if we weren't resuming or setSession failed
            if !isResuming || self.isAuthenticated == false {
                self.currentUser = nil
                self.isAuthenticated = false
                _ = KeychainHelper.deleteSession() // Clean up invalid session
            } else {
                // If resuming and validation failed, keep showing the error from setSession
                print("AuthViewModel: Keeping existing error message from setSession failure.")
            }
        }
        isLoading = false
        print("AuthViewModel: Validation complete.")
    }

    func updateUserState(isAuthenticated: Bool, user: User?) {
        self.isAuthenticated = isAuthenticated
        self.currentUser = user
        self.errorMessage = nil // Clear errors on successful state change

        // Save session to Keychain on successful login/signup
        if isAuthenticated {
            Task {
                do {
                    // Retrieve the current session after login/signup to get tokens
                    let session = try await SupabaseManager.shared.client.auth.session
                    print("AuthViewModel: Saving session to Keychain after state update.")
                    let success = KeychainHelper.saveSession(accessToken: session.accessToken, refreshToken: session.refreshToken)
                    if !success {
                        print("AuthViewModel: WARNING - Failed to save session to Keychain after login/signup.")
                        // Decide how to handle this - maybe show an error?
                    }
                } catch {
                    print("AuthViewModel: ERROR - Could not get session to save after login/signup: \(error.localizedDescription)")
                    // Cannot save session if we can't retrieve it
                }
            }
        }
        // Note: Keychain deletion is handled in signOut
    }

    func setError(message: String) {
        self.errorMessage = message
        self.isAuthenticated = false // Assume error means not authenticated
        self.currentUser = nil
        // Consider deleting keychain here too? Maybe not, could be temporary error.
    }

    func signOut() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await SupabaseManager.shared.signOut()
                print("AuthViewModel: Sign out successful via Supabase.")
                // Clear state *before* deleting from keychain
                updateUserState(isAuthenticated: false, user: nil)
                // Delete session from Keychain
                let deleteSuccess = KeychainHelper.deleteSession()
                if !deleteSuccess {
                    print("AuthViewModel: WARNING - Failed to delete session from Keychain during sign out.")
                }
                print("User signed out successfully.")
            } catch {
                print("Sign out failed: \(error.localizedDescription)")
                // If Supabase signout fails, don't delete local session yet?
                // Or maybe force delete local session anyway?
                // For now, just show error:
                setError(message: "Sign out failed: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
} 