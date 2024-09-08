//
//  DessertViewModel.swift
//  Recipes
//
//  Created by Wyeth Shamp on 9/6/24.
//

import Foundation

@MainActor
class DessertViewModel: ObservableObject {
    // use property wrapper for injecting meal client
    @MealClientDependency
    private var mealClient: MealClient
    private let mealId: String
    @Published var serviceState: ServiceState = .idle
    @Published var mealName: String = ""
    @Published var errorHandler: ErrorHandler? = nil
    @Published var imageUrlString: String = ""
    @Published var instructions: String = ""
    @Published var ingredients: [Ingredient] = []
    
    
    init(mealId: String,
         mealClient: MealClient? = nil) {
        self.mealId = mealId
        if let mealClient = mealClient {
            self._mealClient = MealClientDependency(wrappedValue: mealClient)
        }
    }
    
    func getMeal() async {
        serviceState = .loading
        do {
            let response = try await mealClient.getMealDetails(mealId)
            
            if let mealDetails = response.meals.first {
                serviceState = .idle
                mealName = mealDetails.name
                imageUrlString = mealDetails.imageThumbUrlString
                instructions = mealDetails.instructions
                ingredients = mealDetails.ingredients
            } else {
                serviceState = .failure
                mealName = ""
                imageUrlString = ""
                instructions = ""
                ingredients = []
                errorHandler = ErrorHandler(message: "Invalid Meal Id")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            serviceState = .failure
            errorHandler = ErrorHandler(message: error.localizedDescription)
        }
    }
}
