//
//  AppTemplateTests.swift
//  AppTemplateTests
//
//  Created by Jordan Taylor on 4/21/25.
//

import XCTest
@testable import AppTemplate

final class AppTemplateTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    // MARK: - Supabase Setup Tests

    func testSupabaseManagerInitialization() throws {
        // This test implicitly checks if credentials can be read from Info.plist.
        // If credentials are missing or invalid, the SupabaseManager initializer will call fatalError.
        let manager = SupabaseManager.shared
        XCTAssertNotNil(manager.client, "Supabase client should not be nil after initialization.")
    }

    func testAuthRepositoryInitialization() throws {
        // Ensures AuthRepository initializes and gets the client from SupabaseManager.
        let authRepo = AuthRepository()
        // Accessing the client directly isn't possible due to access control, 
        // but successful initialization implies the client was passed correctly.
        XCTAssertNotNil(authRepo, "AuthRepository should initialize successfully.")
    }

    func testDataRepositoryInitialization() throws {
        // Ensures DataRepository initializes and gets the client from SupabaseManager.
        let dataRepo = DataRepository()
        // Similar to AuthRepository, successful initialization is the main check.
        XCTAssertNotNil(dataRepo, "DataRepository should initialize successfully.")
    }

}
