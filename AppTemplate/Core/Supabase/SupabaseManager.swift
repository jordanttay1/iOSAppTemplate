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
} 