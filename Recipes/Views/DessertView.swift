//
//  DessertView.swift
//  Recipes
//
//  Created by Wyeth Shamp on 9/6/24.
//

import SwiftUI

struct DessertView: View {
    @StateObject var viewModel: DessertViewModel
    @Environment(\.dismiss) var dismiss
    init(viewModel: DessertViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            // switch on service state and render view accordingly
            switch viewModel.serviceState {
            case .idle:
                ScrollView {
                    VStack {
                        AsyncImage(url: URL(string: viewModel.imageUrlString)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .clipRoundedCorner(10, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                        } placeholder: {
                            Color.gray
                                .frame(height: 350)
                        }
                    
                        Divider().padding(.vertical)
                        HStack {
                            Text("Ingredients")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        Spacer().frame(height: 10)
                        ForEach(viewModel.ingredients) { ingredient in
                            HStack {
                                Text("\u{2022}")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text(ingredient.measurement).font(.subheadline)
                                Text(ingredient.name).font(.subheadline)
                                Spacer()
                            }
                        }
                        Divider().padding(.vertical)
                        HStack {
                            Text("Instructions")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        Spacer().frame(height: 10)
                        Text(viewModel.instructions)
                            .font(.subheadline)
                        Divider().padding(.vertical)
                    }.padding()
                }
                .navigationBarTitle(Text(viewModel.mealName), displayMode: .large)
            case .loading:
                ProgressView()
                    .scaleEffect(2.0)
                    .opacity(0.5)
            case .failure:
                //if we are failed we show an empty view as the alert will be presented. We 
                //dismiss when the alert is closed so user will never see this without
                // the alert
                    
                EmptyView()
            }

        }
        
        .alert(item: $viewModel.errorHandler) { handler in
            Alert(title: Text("Error"), message: Text(handler.message), dismissButton: .default(Text("Ok")) {
                dismiss()
            })
        }
        .task {
            await viewModel.getMeal()
        }
    }
}

//preview valid
#Preview {
    NavigationView {
        DessertView(viewModel: DessertViewModel(mealId: "53049"))
    }
}

//Preview error
#Preview {
    DessertView(viewModel: DessertViewModel(mealId: ""))
}
