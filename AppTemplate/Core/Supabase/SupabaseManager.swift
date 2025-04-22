//
//  SupabaseManager.swift
//  AppTemplate
//
//  Created by AI Assistant
//

import Foundation
import Supabase

class SupabaseManager {
    // Shared instance
    static let shared = SupabaseManager()

    // Supabase client
    let client: SupabaseClient

    private init() {
        // Retrieve Supabase URL and Anon Key from Info.plist (populated by xcconfig)
        guard let supabaseURLString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let supabaseURL = URL(string: supabaseURLString),
              let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            fatalError("Supabase URL or Key not found in Info.plist. Check configuration and Secrets.xcconfig.")
        }

        // Initialize the Supabase client
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        print("SupabaseManager initialized successfully.")
    }

    func initialize() {
        // This function can be called from the App struct or AppDelegate
        // Ensures the singleton is created early, triggering the init
        _ = SupabaseManager.shared
    }

    // MARK: - Authentication

    func signInWithEmail(email: String, password: String) async throws -> User {
        // signIn returns a Session, we need the user from it
        let session = try await client.auth.signIn(email: email, password: password)
        return session.user
    }

    func signUpWithEmail(email: String, password: String) async throws -> User {
        // signUp returns an AuthResponse, we need the user from it
        let authResponse = try await client.auth.signUp(email: email, password: password)
        return authResponse.user
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    // MARK: - Database Operations

    // Generic function to fetch data from a table
    // T must conform to Decodable and match the structure of your table rows
    func fetchData<T: Decodable>(tableName: String) async throws -> [T] {
        let query = client.database.from(tableName).select()
        let response: [T] = try await query.execute().value
        return response
    }

    // Add functions for insert, update, delete as needed
    // Example Insert:
    /*
    func insertData<T: Encodable>(tableName: String, data: T) async throws {
        try await client.database.from(tableName).insert(data).execute()
    }
    */
} 