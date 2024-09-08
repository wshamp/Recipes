//
//  TestMealClient.swift
//  RecipesTests
//
//  Created by Wyeth Shamp on 9/6/24.
//

import Foundation
@testable import Recipes


// Create a MealCleint for testing
extension MealClient {
    static let testValue = Self.test()
    static func test() -> Self {
        class BundleIdentifier {}
        let bundle = Bundle.main//Bundle(for: BundleIdentifier.self)
        return Self(getDesserts: {
            print("In Tests")
            
            guard let url = bundle.url(forResource: "DessertsResponse", withExtension: "json") else {
                throw URLError(.fileDoesNotExist)
            }
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(GetDessertsResponse.self, from: data)
        }, getMealDetails: { mealId in
            print("In Tests")
            guard let url = bundle.url(forResource: "MealResponse\(mealId)", withExtension: "json") else {
                return GetMealDetailsResponse(meals: [])
            }
            let data = try Data(contentsOf: url)
            
            return try JSONDecoder().decode(GetMealDetailsResponse.self, from: data)
        })
    }
}


