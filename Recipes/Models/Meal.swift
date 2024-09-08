//
//  Meal.swift
//  Recipes
//
//  Created by Wyeth Shamp on 9/4/24.
//

import Foundation

struct Meal: Decodable, Identifiable, Equatable {
    let mealId: String
    let name: String
    let imageThumbUrlString: String
    
    var id: String {
        return mealId
    }
    
    enum CodingKeys: String, CodingKey {
        case mealId = "idMeal"
        case name = "strMeal"
        case imageThumbUrlString = "strMealThumb"
    }
}
