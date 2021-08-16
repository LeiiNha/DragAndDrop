//
//  CGRect+Random.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 15/08/2021.
//

import UIKit

public extension CGFloat {
    static var random: CGFloat { return CGFloat(arc4random()) / CGFloat(UInt32.max) }

    static func random(between x: CGFloat, and y: CGFloat) -> CGFloat {
        let (start, end) = x < y ? (x, y) : (y, x)
        return start + CGFloat.random * (end - start)
    }
}

public extension CGRect {
    var randomPoint: CGPoint {
        var point = CGPoint()
        point.x = CGFloat.random(between: origin.x, and: origin.x + width)
        point.y = CGFloat.random(between: origin.y, and: origin.y + height)
        return point
    }
}
