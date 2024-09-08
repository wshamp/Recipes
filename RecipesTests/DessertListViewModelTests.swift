//
//  DessertListViewModelTests.swift
//  RecipesTests
//
//  Created by Wyeth Shamp on 9/7/24.
//

import XCTest
import Combine
@testable import Recipes
final class DessertListViewModelTests: XCTestCase {

    var dessertListViewModel: DessertListViewModel!
    
    @MainActor
    override func setUpWithError() throws {
        self.dessertListViewModel = DessertListViewModel(mealClient: MealClient.testValue)
    }

    override func tearDownWithError() throws {
        self.dessertListViewModel = nil
    }
    
    // this tests that setting the sortOrder will change the filteredMeals array accordingly
    @MainActor
    func testSort() async throws {
        await dessertListViewModel.getDesserts()
        XCTAssertEqual(dessertListViewModel.sortOrder, SortOrder.alphabetical)
        let alphaSortedMeals = dessertListViewModel.filteredMeals.sorted(by: { $0.name < $1.name })
        let reverseSortedMeals = dessertListViewModel.filteredMeals.sorted(by: { $0.name > $1.name })
        let filteredMealsChanged = expectation(description: "Filtered Meals Reversed")
        XCTAssertEqual(dessertListViewModel.filteredMeals, alphaSortedMeals)
        
        var cancelable = dessertListViewModel.$filteredMeals.sink { filteredMeals in
            if filteredMeals == reverseSortedMeals {
                filteredMealsChanged.fulfill()
            }
        }
        dessertListViewModel.sortOrder = .reverse
        await fulfillment(of: [filteredMealsChanged], timeout: 2.0)
        
        
        XCTAssertEqual(dessertListViewModel.filteredMeals, reverseSortedMeals)
        cancelable.cancel()
        let filteredMealsChangedToAlpha = expectation(description: "Filtered Meals changed back")
        cancelable = dessertListViewModel.$filteredMeals.sink { filteredMeals in
            if filteredMeals == alphaSortedMeals {
                filteredMealsChangedToAlpha.fulfill()
            }
        }
        dessertListViewModel.sortOrder = .alphabetical
        await fulfillment(of: [filteredMealsChangedToAlpha], timeout: 2.0)
        XCTAssertEqual(dessertListViewModel.filteredMeals, alphaSortedMeals)
        cancelable.cancel()
    }
    
    // This will test that setting the search text will change the filtered meals array accordingly
    @MainActor
    func testSearch() async throws {
        let filterCountChangeToZeroExpectation = expectation(description: "Filter Count should change to 0")
        await dessertListViewModel.getDesserts()
        let filteredMealsCount = dessertListViewModel.filteredMeals.count
        XCTAssertEqual(dessertListViewModel.searchText, "")
        XCTAssertTrue(filteredMealsCount > 0)
        var cancelable = dessertListViewModel.$filteredMeals.sink { filteredMeals in
            if filteredMeals.count == 0 {
                filterCountChangeToZeroExpectation.fulfill()
            }
        }
        
        dessertListViewModel.searchText = "zzzz"
        await fulfillment(of: [filterCountChangeToZeroExpectation], timeout: 2.0)

        XCTAssertTrue(dessertListViewModel.filteredMeals.count == 0)
        XCTAssertEqual(dessertListViewModel.searchText, "zzzz")
        cancelable.cancel()
        let filterCountChangeBack = expectation(description: "Filter count should change to more than 0")
        cancelable = dessertListViewModel.$filteredMeals.sink { filteredMeals in
            if filteredMeals.count == filteredMealsCount {
                filterCountChangeBack.fulfill()
            }
        }
        dessertListViewModel.searchText = ""
        await fulfillment(of: [filterCountChangeBack], timeout: 2.0)
        XCTAssertTrue(dessertListViewModel.filteredMeals.count == filteredMealsCount)
        XCTAssertEqual(dessertListViewModel.searchText, "")
        cancelable.cancel()
        
    }
    
    // This will test the success state of fetching desserts
    // verifying our models decode
    @MainActor
    func testGetDessertsSuccess() async throws {
        var cancellables = Set<AnyCancellable>()
        let loadingExpectation = expectation(description: "Status should be set to loading")
        let idleExpectation = expectation(description: "Status should be set to idle")
        idleExpectation.expectedFulfillmentCount = 2
        dessertListViewModel.$serviceState.sink { status in
            if status == .loading {
                loadingExpectation.fulfill()
            }
            if status == .idle {
                idleExpectation.fulfill()
            }
        }
        .store(in: &cancellables)
        await dessertListViewModel.getDesserts()
        await fulfillment(of: [loadingExpectation, idleExpectation], timeout: 2.0)
        XCTAssertTrue(dessertListViewModel.filteredMeals.count > 0)
    }
    
    // this is the failure state
    @MainActor
    func testGetDessertsFailure() async throws {
        self.dessertListViewModel = DessertListViewModel(mealClient: MealClient(getDesserts: {
            throw URLError(.badURL)
        }, getMealDetails: { _ in
            throw URLError(.badURL)
        }))
        var cancellables = Set<AnyCancellable>()
        let loadingExpectation = expectation(description: "Status should be set to loading")
        let failedExpectation = expectation(description: "Status should be set to failed")
        dessertListViewModel.$serviceState.sink { status in
            if status == .loading {
                loadingExpectation.fulfill()
            }
            if status == .failure {
                failedExpectation.fulfill()
            }
        }
        .store(in: &cancellables)
        XCTAssertNil(dessertListViewModel.errorHandler)
        await dessertListViewModel.getDesserts()
        await fulfillment(of: [loadingExpectation, failedExpectation], timeout: 2.0)
        XCTAssertTrue(dessertListViewModel.filteredMeals.count == 0)
        XCTAssertNotNil(dessertListViewModel.errorHandler)
    }
}
