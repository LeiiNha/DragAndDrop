//
//  Action.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import Foundation

enum Action {
    case dragDrop
    case pressed(shape: Shape)
    case undo
    case removeAll
    case longTapRemove
}
