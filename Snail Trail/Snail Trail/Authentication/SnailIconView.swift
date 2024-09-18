//
//  SnailIconView.swift
//  Snail Trail
//
//  Created by Logan Gutknecht on 9/18/24.
//

import SwiftUI

struct SnailIconView: View {
    var color: Color
    
    var body: some View {
        SnailShape()
            .stroke(color, lineWidth: 2)
            .frame(width: 24, height: 24)
    }
}

struct SnailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Scale the path to fit in the given rect
        let scale = min(rect.width, rect.height) / 24
        
        path.move(to: CGPoint(x: 2 * scale, y: 13 * scale))
        path.addCurve(to: CGPoint(x: 14 * scale, y: 13 * scale),
                      control1: CGPoint(x: 2 * scale, y: 19 * scale),
                      control2: CGPoint(x: 14 * scale, y: 19 * scale))
        path.addCurve(to: CGPoint(x: 10 * scale, y: 13 * scale),
                      control1: CGPoint(x: 14 * scale, y: 9 * scale),
                      control2: CGPoint(x: 10 * scale, y: 9 * scale))
        path.addCurve(to: CGPoint(x: 12 * scale, y: 13 * scale),
                      control1: CGPoint(x: 10 * scale, y: 15 * scale),
                      control2: CGPoint(x: 12 * scale, y: 15 * scale))
        
        path.move(to: CGPoint(x: 2 * scale, y: 21 * scale))
        path.addEllipse(in: CGRect(x: 2 * scale, y: 5 * scale, width: 16 * scale, height: 16 * scale))
        
        path.move(to: CGPoint(x: 2 * scale, y: 21 * scale))
        path.addLine(to: CGPoint(x: 14 * scale, y: 21 * scale))
        path.addCurve(to: CGPoint(x: 22 * scale, y: 13 * scale),
                      control1: CGPoint(x: 18.4 * scale, y: 21 * scale),
                      control2: CGPoint(x: 22 * scale, y: 17.4 * scale))
        path.addLine(to: CGPoint(x: 22 * scale, y: 7 * scale))
        path.addCurve(to: CGPoint(x: 18 * scale, y: 7 * scale),
                      control1: CGPoint(x: 22 * scale, y: 5 * scale),
                      control2: CGPoint(x: 18 * scale, y: 5 * scale))
        path.addLine(to: CGPoint(x: 18 * scale, y: 13 * scale))
        
        path.move(to: CGPoint(x: 18 * scale, y: 3 * scale))
        path.addLine(to: CGPoint(x: 19.1 * scale, y: 5.2 * scale))
        
        path.move(to: CGPoint(x: 22 * scale, y: 3 * scale))
        path.addLine(to: CGPoint(x: 20.9 * scale, y: 5.2 * scale))
        
        return path
    }
}

struct SnailIconView_Previews: PreviewProvider {
    static var previews: some View {
        SnailIconView(color: .blue)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
