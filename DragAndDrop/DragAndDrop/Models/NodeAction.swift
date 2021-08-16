//
//  Action.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import Foundation

enum NodeAction {
    case dragDrop(log: DragDropLog)
    case spawn(shape: Shape, uuid: String)
    case removeLastSpawn
    case removeFirstSpawn
    case undoLastDragDrop(log: DragDropLog)
    case removeAll(shapes: [Shape])
    case longTapRemove(uuid: String)
}

struct DragDropLog {
    let x: Float
    let y: Float
    let uuid: String
}
