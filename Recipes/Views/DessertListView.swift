//
//  DessertListView.swift
//  Recipes
//
//  Created by Wyeth Shamp on 9/5/24.
//

import SwiftUI

struct DessertListView: View {
    @StateObject var viewModel: DessertListViewModel
    @FocusState var focusedField: DessertListViewFocusField?
    init(viewModel: DessertListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    static let horizontalPadding: CGFloat = 15.0
    static let gridSpacing: CGFloat = 20.0
    let columns = [
        GridItem(.flexible(), spacing: gridSpacing),
        GridItem(.flexible(), spacing: gridSpacing)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                GeometryReader { proxy in
                    let imageWidth = (proxy.size.width - (DessertListView.horizontalPadding * 2) - DessertListView.gridSpacing) / 2
                    VStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            
                            TextField("Search", text: $viewModel.searchText)
                                .focused($focusedField, equals: .search)
                                .accentColor(Color.gray)
                                .frame(height: 40)
                            
                            if viewModel.searchText.count > 0 {
                                Button(action: {
                                    viewModel.searchText = ""
                                    focusedField = nil
                                }, label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                })
                                .padding(.trailing, 10)
                            }
                        }.overlayRoundedCorner(5, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                        .padding()

                        ScrollView(.vertical) {
                            if viewModel.filteredMeals.count > 0 {
                                LazyVGrid(columns: columns, spacing: 30) {
                                    ForEach(viewModel.filteredMeals) { meal in
                                        NavigationLink(destination: DessertView(viewModel: DessertViewModel(mealId: meal.mealId))) {
                                            VStack {
                                                
                                                let imageURL:URL? = URL(string: meal.imageThumbUrlString)
                                                AsyncImage(url: imageURL) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        // AsyncImage phase is empty whith
                                                        // nil url and when it is loading
                                                        // but we want to show different views for each
                                                        ZStack {
                                                            Color.gray.opacity(0.5)
                                                            
                                                            if let _ = imageURL {
                                                                ProgressView()
                                                                    .scaleEffect(2.0)
                                                            } else {
                                                                Image(systemName: "photo")
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fit)
                                                                    .tint(Color.secondary)
                                                                    .padding()
                                                                
                                                            }
                                                        }
                                                        .aspectRatio(1, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                                        .frame(width: imageWidth, height: imageWidth)
                                                        .clipRoundedCorner(10, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                                                        
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .aspectRatio(1, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                                            .frame(width: imageWidth, height: imageWidth)
                                                            .clipRoundedCorner(10, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                                                        
                                                    case .failure:
                                                        ZStack {
                                                            Color.gray.opacity(0.5)
                                                            Image(systemName: "photo")
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .tint(Color.secondary)
                                                                .padding()
                                                            
                                                        }
                                                        .aspectRatio(1, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                                        .frame(width: imageWidth, height: imageWidth)
                                                        .clipRoundedCorner(10, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                                                        
                                                    @unknown default:
                                                        ZStack {
                                                            Color.gray.opacity(0.5)
                                                            Image(systemName: "photo")
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .tint(Color.secondary)
                                                                .padding()
                                                            
                                                        }
                                                        .aspectRatio(1, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                                        .frame(width: imageWidth, height: imageWidth)
                                                        .clipRoundedCorner(10, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                                                    }
                                                }
                                                Text(meal.name).frame(height: 50)
                                                    .font(.headline)
                                                    .multilineTextAlignment(.center)
                                                    .minimumScaleFactor(0.8)
                                                
                                            }.frame(height: imageWidth + 50)
                                        }
                                    }
                                }.padding(.top)
                            } else if viewModel.serviceState == .idle {
                                Text("No Results:\nPull to refresh or clear your search text.")
                                    .multilineTextAlignment(.center)
                            } else {
                                EmptyView()
                            }
                        }
                        .refreshable {
                            Task {
                                await viewModel.getDesserts()
                            }
                        }
                        .padding(.horizontal, DessertListView.horizontalPadding)
                        
                    }
                    
                }
            }
            .navigationBarTitle(Text("Desserts"), displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Button {
                                viewModel.sortOrder = order
                            } label: {
                                HStack {
                                    Text(order.rawValue)
                                    Spacer()
                                    if viewModel.sortOrder == order {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        switch viewModel.sortOrder {
                        case .alphabetical:
                            HStack {
                                Text("Aa ")
                                Image(systemName: "arrow.up").font(.caption)
                            }
                        case .reverse:
                            HStack {
                                Text("Aa")
                                Image(systemName: "arrow.down").font(.caption)
                            }
                        }
                    }
                }
            }
            .task {
                await viewModel.getDesserts()
            }
        }
    }
}

#Preview {
    DessertListView(viewModel: DessertListViewModel())
}
