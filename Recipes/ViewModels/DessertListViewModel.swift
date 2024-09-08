//
//  DessertListViewModel.swift
//  Recipes
//
//  Created by Wyeth Shamp on 9/5/24.
//

import Foundation
import Combine
@MainActor
class DessertListViewModel: ObservableObject {
    // use property wrapper for injecting meal client
    @MealClientDependency
    private var mealClient: MealClient
    @Published var serviceState: ServiceState = .idle
    @Published var filteredMeals: [Meal] = []
    @Published var errorHandler: ErrorHandler? = nil
    @Published var searchText: String = ""
    @Published var sortOrder: SortOrder = .alphabetical
    
    private var meals: [Meal] = []
    private var cancellables = Set<AnyCancellable>()
    
    
    init(mealClient: MealClient? = nil) {
        if let mealClient = mealClient {
            self._mealClient = MealClientDependency(wrappedValue: mealClient)
        }
        setupPropertyObservation()
    }
    
    
    // Here we will observe changes to the two properties that affect the list
    // Sort order and search text
    // We combine the two publishers and mutate the filtered meals accordingly.
    
    func setupPropertyObservation() {
        Publishers.CombineLatest(
            $searchText
                .debounce(for: .milliseconds(300), scheduler: RunLoop.main), 
            $sortOrder).map { [weak self] searchText, sortOrder in
                
                guard let self = self else { return [] }

                var filteredMeals = self.meals
                if !searchText.isEmpty {
                    filteredMeals = filteredMeals.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                }
                switch sortOrder {
                case .alphabetical:
                    filteredMeals.sort { $0.name < $1.name }
                case .reverse:
                    filteredMeals.sort { $0.name > $1.name }
                }
                
            return filteredMeals
        }.assign(to: \.filteredMeals, on: self)
        .store(in: &cancellables)
    }
    
    
    func getDesserts() async {
        serviceState = .loading
        do {
            let response = try await mealClient.getDesserts()
            meals = response.meals
            filteredMeals = meals
            switch sortOrder {
            case .alphabetical:
                filteredMeals = meals.sorted(by: { $0.name < $1.name })
            case .reverse:
                filteredMeals = meals.sorted(by: { $0.name > $1.name })
            }
            if !searchText.isEmpty {
                filteredMeals = filteredMeals.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            } 
            serviceState = .idle
        } catch {
            meals = []
            filteredMeals = meals
            print("Error: \(error.localizedDescription)")
            serviceState = .failure
            errorHandler = ErrorHandler(message: error.localizedDescription)
        }
    }
}

enum SortOrder: String, CaseIterable {
    case alphabetical = "Alphabetical"
    case reverse = "Reverse"
}

enum DessertListViewFocusField: Int, Hashable {
    case search = 1
}
