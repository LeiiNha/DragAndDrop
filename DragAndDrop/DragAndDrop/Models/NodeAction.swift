//
//  Action.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import Foundation

enum NodeAction {
    case dragDrop(log: NodePosition)
    case spawn(shape: Shape, log: NodePosition)
    case removeLastSpawn
    case removeFirstSpawn
    case undoLastDragDrop(log: NodePosition)
    case removeAll(shapes: [Shape])
    case longTapRemove(uuid: String)
}

struct NodePosition {
    let x: Float
    let y: Float
    let uuid: String
}
