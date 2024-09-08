//
//  RecipesApp.swift
//  Recipes
//
//  Created by Wyeth Shamp on 9/4/24.
//

import SwiftUI

@main
struct RecipesApp: App {
    var body: some Scene {
        WindowGroup {
            DessertListView(viewModel: DessertListViewModel())
        }
    }
}
