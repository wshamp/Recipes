//
//  ViewModifiers.swift
//  Recipes
//
//  Created by Wyeth Shamp on 9/6/24.
//

import SwiftUI

extension View {
    func clipRoundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
    func overlayRoundedCorner(_ radius: CGFloat, corners: UIRectCorner, strokeColor: Color = Color.gray.opacity(0.2), lineWidth: CGFloat = 1.0) -> some View {

        overlay(RoundedCorner(radius: radius, corners: corners).stroke(strokeColor, lineWidth: lineWidth))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ErrorHandler: Identifiable {
    let id = UUID()
    let message: String
}
