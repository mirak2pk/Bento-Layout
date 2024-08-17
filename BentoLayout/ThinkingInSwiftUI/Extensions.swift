//
//  Extensions.swift
//  ThinkingInSwiftUI
//
//  Created by MacBook on 15/8/2024.
//

import SwiftUI

struct RoundedRectangleGradient: ViewModifier {
    var radius: CGFloat
    var style: RoundedCornerStyle
    var padding: CGFloat
    var gradientColor: [Color]
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(RoundedRectangle(cornerRadius: radius, style: style)
                    .fill(LinearGradient(colors: gradientColor,
                                         startPoint: .bottomTrailing, endPoint: .topLeading)))
    }
}

struct RoundedRectangleBackground: ViewModifier {
    var radius: CGFloat
    var style: RoundedCornerStyle
    var padding: CGFloat
    var color: Material
    var hPadding: CGFloat
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .padding(.horizontal, hPadding)
            .background(RoundedRectangle(cornerRadius: radius, style: style)
                    .fill(color))
            //.shadow(color: .black.opacity(0.08), radius: 5, y: 5)
    }
}

extension View {
    /// this is a background RoundedRectangle that has different properties to be adjusted, and some initial values
    /// to call the modifier
    func recGradient(radius: CGFloat = 25, style: RoundedCornerStyle = .continuous, padding: CGFloat = 20, gradientColor: [Color]) -> some View {
        modifier(RoundedRectangleGradient(radius: radius,
                                            style: .continuous,
                                            padding: padding,
                                            gradientColor: gradientColor))
    }
    
    func recBackground(radius: CGFloat = 25, style: RoundedCornerStyle = .continuous, padding: CGFloat = 20, color: Material, hPadding: CGFloat = 5) -> some View {
        modifier(RoundedRectangleBackground(radius: radius,
                                            style: .continuous,
                                            padding: padding,
                                            color: color,
                                            hPadding: hPadding))
    }
    
    /// Aligner is a tool that for test alignment, fast testing that allows developer to know the maxWidth that he can reach
    /// after a certain View (Text) get affected by the width of testing vview
    func aligner(_ width: CGFloat, _ alignment: Alignment = .leading, _ color: Color = .red) -> some View {
        modifier(ViewAligner(width: width, alignment: alignment, color: color))
    }
}

struct ViewAligner: ViewModifier{
    var width: CGFloat
    var alignment: Alignment
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .frame(width: width, alignment: alignment)
            .background(color)
    }
}
