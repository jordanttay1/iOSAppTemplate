//
//  DataRepository.swift
//  AppTemplate
//
//  Created by AI Assistant
//

import Foundation
import Supabase

protocol DataRepositoryProtocol {
    // Define data fetching/manipulation methods here (e.g., fetchData, saveData)
}

class DataRepository: DataRepositoryProtocol {
    private let client: SupabaseClient

    init() {
        // Initialize with the shared Supabase client
        self.client = SupabaseManager.shared.client
        // print("DataRepository initialized (placeholder)") // No longer needed
    }

    // Implement protocol methods here
} 