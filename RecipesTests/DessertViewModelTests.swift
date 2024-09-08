//
//  DessertViewModelTests.swift
//  RecipesTests
//
//  Created by Wyeth Shamp on 9/6/24.
//

import XCTest
import Combine
@testable import Recipes
final class DessertViewModelTests: XCTestCase {
    
    // So to test the service state changing to loading and then to its final state either idle or failed
    // we need to observe the state change with combine because it happens in the async call. 
    
    @MainActor
    func testGetMealSuccess() async throws {
        var cancellables = Set<AnyCancellable>()
        let dessertViewModel = DessertViewModel(mealId: "53049", mealClient: MealClient.testValue)
        let loadingExpectation = expectation(description: "Status should be set to loading")
        let idleExpectation = expectation(description: "Status should be set to idle")
        idleExpectation.expectedFulfillmentCount = 2
        dessertViewModel.$serviceState.sink { status in
            if status == .loading {
                loadingExpectation.fulfill()
            }
            if status == .idle {
                idleExpectation.fulfill()
            }
        }
        .store(in: &cancellables)
        await dessertViewModel.getMeal()
        await fulfillment(of: [loadingExpectation, idleExpectation], timeout: 2.0)
        XCTAssertEqual(dessertViewModel.mealName, "Apam balik")
        XCTAssertEqual(dessertViewModel.imageUrlString, "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg")
        XCTAssertEqual(dessertViewModel.instructions, "Mix milk, oil and egg together. Sift flour, baking powder and salt into the mixture. Stir well until all ingredients are combined evenly.\r\n\r\nSpread some batter onto the pan. Spread a thin layer of batter to the side of the pan. Cover the pan for 30-60 seconds until small air bubbles appear.\r\n\r\nAdd butter, cream corn, crushed peanuts and sugar onto the pancake. Fold the pancake into half once the bottom surface is browned.\r\n\r\nCut into wedges and best eaten when it is warm.")
        XCTAssertEqual(dessertViewModel.ingredients, [Ingredient(id: "1", name: "Milk", measurement: "200ml"),
                                                      Ingredient(id: "2", name: "Oil", measurement: "60ml"),
                                                      Ingredient(id: "3", name: "Eggs", measurement: "2"),
                                                      Ingredient(id: "4", name: "Flour", measurement: "1600g"),
                                                      Ingredient(id: "5", name: "Baking Powder", measurement: "3 tsp"),
                                                      Ingredient(id: "6", name: "Salt", measurement: "1/2 tsp"),
                                                      Ingredient(id: "7", name: "Unsalted Butter", measurement: "25g"),
                                                      Ingredient(id: "8", name: "Sugar", measurement: "45g"),
                                                      Ingredient(id: "9", name: "Peanut Butter", measurement: "3 tbs")])
    }
    
    @MainActor
    func testGetMealFailure() async throws {
        var cancellables = Set<AnyCancellable>()
        let dessertViewModel = DessertViewModel(mealId: "asdffsa", mealClient: MealClient.testValue)
        let loadingExpectation = expectation(description: "Status should be set to loading")
        let failedExpectation = expectation(description: "Status should be set to failed")
        dessertViewModel.$serviceState.sink { status in
            if status == .loading {
                loadingExpectation.fulfill()
            }
            if status == .failure {
                failedExpectation.fulfill()
            }
        }
        .store(in: &cancellables)
        await dessertViewModel.getMeal()
        await fulfillment(of: [loadingExpectation, failedExpectation], timeout: 2.0)
        XCTAssertEqual(dessertViewModel.mealName, "")
        XCTAssertEqual(dessertViewModel.imageUrlString, "")
        XCTAssertEqual(dessertViewModel.instructions, "")
        XCTAssertEqual(dessertViewModel.ingredients.count, 0)
        XCTAssertEqual(dessertViewModel.serviceState, .failure)
        XCTAssertNotNil(dessertViewModel.errorHandler)
        XCTAssertEqual(dessertViewModel.errorHandler?.message, "Invalid Meal Id")
    }
}
