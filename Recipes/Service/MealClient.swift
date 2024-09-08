//
//  MealService.swift
//  Recipes
//
//  Created by Wyeth Shamp on 9/5/24.
//

import Foundation
import SwiftUI

enum MealServiceConstants {
    static let desertsUrlString = "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert"
    static let mealUrlString = "https://themealdb.com/api/json/v1/1/lookup.php?i="
}

struct GetDessertsResponse: Decodable {
    let meals: [Meal]
}

struct GetMealDetailsResponse: Decodable {
    let meals: [MealDetails]
}

// This pattern for client services allows us to define different clients
// for live, preview, and tests. This combined with the property wrapper
// defined below allow us to have default implementations or override them
// as we see fit. This solves the problem with using protocols and mocks
// where any subviews you click into in previews will be using their live
// version. The peroperty wrapper will use the preview implementation when in previews
// and you don't have to do anything


struct MealClient {
    // We store the service calls as properties
    var getDesserts: () async throws -> GetDessertsResponse
    var getMealDetails: (String) async throws -> GetMealDetailsResponse
}

extension MealClient {
    // Here is where we set the default implementations for live and preview. We will set the
    // test implementation in the test target and inject it.
    static let liveValue = Self.live()
    static let previewValue = Self.preview()
    private static func live() -> Self {
        return Self(getDesserts: {
            print("Live")
            guard let url = URL(string: MealServiceConstants.desertsUrlString) else {
                throw URLError(.badURL)
            }
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse,
                    response.statusCode >= 200,
                    response.statusCode < 300 else {
                throw URLError(.badServerResponse)
            }
            
            return try JSONDecoder().decode(GetDessertsResponse.self, from: data)
        }, getMealDetails: { mealId in
            print("Live")
            guard let url = URL(string: MealServiceConstants.mealUrlString + mealId) else {
                throw URLError(.badURL)
            }
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse,
                    response.statusCode >= 200,
                    response.statusCode < 300 else {
                throw URLError(.badServerResponse)
            }
            return try JSONDecoder().decode(GetMealDetailsResponse.self, from: data)
        })
    }

    private static func preview() -> Self {
        guard ProcessInfo.processInfo.isRunningInPreview else {
            fatalError("MockService should only be used in tests or SwiftUI previews.")
        }
        let bundle = Bundle.main//Bundle(for: BundleIdentifier.self)
        return Self(getDesserts: {
            print("In Preview")
            
            guard let url = bundle.url(forResource: "DessertsResponse", withExtension: "json") else {
                throw URLError(.fileDoesNotExist)
            }
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(GetDessertsResponse.self, from: data)
        }, getMealDetails: { mealId in
            print("In Preview")
            guard let url = bundle.url(forResource: "MealResponse\(mealId)", withExtension: "json") else {
                return GetMealDetailsResponse(meals: [])
            }
            let data = try Data(contentsOf: url)
            
            return try JSONDecoder().decode(GetMealDetailsResponse.self, from: data)
        })
    }
}


extension ProcessInfo {
    var isRunningInPreview: Bool {
        return environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}


@propertyWrapper
struct MealClientDependency {
    private var client: MealClient

    // this init will let us override and inject our own version when
    // we want to
    init(wrappedValue: MealClient) {
        self.client = wrappedValue
    }
    
    // this init will check if we are in previews and use the preview implenentation
    // only if we are in debug.
    // if this is a release build we use live by default
    init() {
        #if DEBUG
        if ProcessInfo.processInfo.isRunningInPreview {
            self.client = .previewValue
        } else {
            self.client = .liveValue
        }
        #else
        self.client = .liveValue
        #endif
    }

    var wrappedValue: MealClient {
        return client
    }
}

