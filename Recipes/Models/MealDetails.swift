//
//  MealDetails.swift
//  Recipes
//
//  Created by Wyeth Shamp on 9/4/24.
//

import Foundation

struct MealDetails: Decodable, Identifiable {
    let mealId: String
    let name: String
    let instructions: String
    let imageThumbUrlString: String
    let ingredients: [Ingredient]
    
    var id: String {
        return mealId
    }
    
    init(mealId: String, 
         name: String,
         instructions: String,
         imageThumbUrlString: String,
         ingredients: [Ingredient]) {
        self.mealId = mealId
        self.name = name
        self.instructions = instructions
        self.imageThumbUrlString = imageThumbUrlString
        self.ingredients = ingredients
    }
    
    enum CodingKeys: String, CodingKey {
        case mealId = "idMeal"
        case name = "strMeal"
        case instructions = "strInstructions"
        case imageThumbUrlString = "strMealThumb"
    }
    
    enum IngredientKeyName: String {
        case ingredient = "strIngredient"
        case measurement = "strMeasure"
    }
    
    struct IngredientKeys: CodingKey {
        
        var stringValue: String
        var intValue: Int?
        
        // this will let us create a dynamic key
        init(ingredientKeyName: IngredientKeyName, suffix: String) {
            self.stringValue = ingredientKeyName.rawValue + suffix
        }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            return nil
        }
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // create a container for just the ingredients
        let intredientContainer = try decoder.container(keyedBy: IngredientKeys.self)
        self.mealId = try container.decode(String.self, forKey: .mealId)
        self.name = try container.decode(String.self, forKey: .name)
        self.instructions = try container.decode(String.self, forKey: .instructions)
        self.imageThumbUrlString = try container.decode(String.self, forKey: .imageThumbUrlString)
        var ingredients: [Ingredient] = []
        // Here we decode the ingredients and mesurments. they come in the Json as seperate fields
        // We want to combine them
        // First loop through all the keys in the intredientContainer
        for key in intredientContainer.allKeys {
            // all the ingredients have the same prefix.
            if key.stringValue.starts(with: IngredientKeyName.ingredient.rawValue) {
                // get the ingredient
                if let ingredient = try intredientContainer.decodeIfPresent(String.self, forKey: key), !ingredient.isEmpty {
                    // extract the number
                    let ingredientNumber = String(key.stringValue.dropFirst(IngredientKeyName.ingredient.rawValue.count))
                    // create the dynamic key using the ingredient number and the measurment prefix
                    let measurementKey = IngredientKeys(ingredientKeyName: .measurement, suffix: ingredientNumber)
                    // get the measurement and create the Ingredient type
                    if let measurement = try intredientContainer.decodeIfPresent(String.self, forKey: measurementKey), !measurement.isEmpty {
                        // use the number for the ingredient id lets us conform to identifiable.
                        ingredients.append(Ingredient(id: ingredientNumber, name: ingredient, measurement: measurement))
                    }
                }
            }
        }
        self.ingredients = ingredients.sorted(by: {$0.id < $1.id})
    }
}

struct Ingredient: Codable, Identifiable, Equatable {
    var id:String = UUID().uuidString
    let name: String
    let measurement: String
}
