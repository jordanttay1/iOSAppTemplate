//
//  KeychainHelper.swift
//  AppTemplate
//
//  Created by AI Assistant
//

import Foundation
import Security

struct KeychainHelper {

    // Use unique keys based on bundle ID or a specific service name
    private static let serviceName = Bundle.main.bundleIdentifier ?? "com.yourapp.default.keychain"
    private static let accessTokenKey = "supabase.accessToken"
    private static let refreshTokenKey = "supabase.refreshToken"

    // MARK: - Save

    static func saveSession(accessToken: String, refreshToken: String) -> Bool {
        // Delete existing tokens first to ensure clean update
        deleteToken(forKey: accessTokenKey)
        deleteToken(forKey: refreshTokenKey)

        let saveAccessTokenSuccess = saveToken(accessToken, forKey: accessTokenKey)
        let saveRefreshTokenSuccess = saveToken(refreshToken, forKey: refreshTokenKey)

        if !saveAccessTokenSuccess || !saveRefreshTokenSuccess {
            print("KeychainHelper: Failed to save one or both tokens.")
            // Attempt cleanup if one failed
            if !saveAccessTokenSuccess { deleteToken(forKey: refreshTokenKey) }
            if !saveRefreshTokenSuccess { deleteToken(forKey: accessTokenKey) }
            return false
        }

        print("KeychainHelper: Session saved successfully.")
        return true
    }

    private static func saveToken(_ token: String, forKey key: String) -> Bool {
        guard let tokenData = token.data(using: .utf8) else {
            print("KeychainHelper: Failed to convert token to data for key: \(key)")
            return false
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: tokenData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly // Good security practice
        ]

        // Delete existing item before adding, handling potential not found error
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("KeychainHelper: Failed to save token for key \(key). Status: \(status)")
            return false
        }
        return true
    }

    // MARK: - Load

    static func loadSession() -> (accessToken: String, refreshToken: String)? {
        guard let accessToken = loadToken(forKey: accessTokenKey), 
              let refreshToken = loadToken(forKey: refreshTokenKey) else {
            print("KeychainHelper: Could not load one or both tokens.")
            return nil
        }
        print("KeychainHelper: Session loaded successfully.")
        return (accessToken, refreshToken)
    }

    private static func loadToken(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess, let retrievedData = dataTypeRef as? Data else {
            if status != errSecItemNotFound {
                 print("KeychainHelper: Failed to load token for key \(key). Status: \(status)")
            }
            return nil
        }

        return String(data: retrievedData, encoding: .utf8)
    }

    // MARK: - Delete

    static func deleteSession() -> Bool {
        let deleteAccessTokenSuccess = deleteToken(forKey: accessTokenKey)
        let deleteRefreshTokenSuccess = deleteToken(forKey: refreshTokenKey)
        
        if deleteAccessTokenSuccess && deleteRefreshTokenSuccess {
            print("KeychainHelper: Session deleted successfully.")
            return true
        } else {
            print("KeychainHelper: Failed to delete one or both tokens.")
            return false // Indicate partial or full failure
        }
    }

    private static func deleteToken(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            print("KeychainHelper: Failed to delete token for key \(key). Status: \(status)")
            return false
        }
        // Treat item not found as success for deletion purposes
        return true
    }
} 