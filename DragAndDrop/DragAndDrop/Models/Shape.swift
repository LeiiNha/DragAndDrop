//
//  Shape.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import Foundation
import SpriteKit

enum Shape: Int, CaseIterable {
    case square
    case circle
    case triangle

    var color: UIColor {
        switch self {
        case .circle: return .green
        case .square: return .red
        case .triangle: return .blue
        }
    }

    var text: String {
        switch self {
        case .circle: return "Circle"
        case .square: return "Square"
        case .triangle: return "Triangle"
        }
    }

    func node(uuid: String) -> SKShapeNode {
        switch self {
        case .circle:
            return SKShapeNode(circleOfRadius: 25, uuid: uuid, color: color)
        case .square:
            return SKShapeNode(rectOf: .init(width: 50, height: 50), uuid: uuid, color: color)
        case .triangle:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0, y: 25.0))
            path.addLine(to: CGPoint(x: 25.0, y: -28.3))
            path.addLine(to: CGPoint(x: -25.0, y: -28.3))
            path.addLine(to: CGPoint(x: 0.0, y: 25.0))
            return SKShapeNode.init(triangleOf: path.cgPath, uuid: uuid, color: color)
        }
    }
}

extension SKShapeNode {
    convenience init(circleOfRadius: CGFloat, uuid: String, color: UIColor) {
        self.init(circleOfRadius: circleOfRadius)
        name = uuid
        fillColor = color
    }

    convenience init(rectOf: CGSize, uuid: String, color: UIColor) {
        self.init(rectOf: rectOf)
        name = uuid
        fillColor = color
    }

    convenience init(triangleOf: CGPath, uuid: String, color: UIColor) {
        self.init(path: triangleOf)
        name = uuid
        fillColor = color
    }
}
