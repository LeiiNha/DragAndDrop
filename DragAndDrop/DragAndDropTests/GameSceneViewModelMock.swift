//
//  GameSceneViewModelMock.swift
//  DragAndDropTests
//
//  Created by Erica Geraldes on 16/08/2021.
//

import Foundation
@testable import DragAndDrop
import Combine

final class GameSceneViewModelMock: Mock, GameSceneViewModelProtocol {
    typealias Method = Function
    var callersCount: [Function : Int]
    init() {
        self.callersCount = .initialized()
    }

    enum Function: Hashable, CaseIterable {
        case dragDrop
        case spawn
        case removeLastSpawn
        case removeFirstSpawn
        case undoLastDragDrop
        case removeAll
        case longTapRemove
    }

    func doNodeAction(nodeAction: NodeAction) {
        switch nodeAction {
        case .dragDrop:
            incrementCounterFor(.dragDrop)
        case .spawn:
            incrementCounterFor(.spawn)
        case .removeLastSpawn:
            incrementCounterFor(.removeLastSpawn)
        case .removeFirstSpawn:
            incrementCounterFor(.removeFirstSpawn)
        case .undoLastDragDrop:
            incrementCounterFor(.undoLastDragDrop)
        case .removeAll:
            incrementCounterFor(.removeAll)
        case .longTapRemove:
            incrementCounterFor(.longTapRemove)
        }
    }

    private var doNodeActionPassthrough: PassthroughSubject<NodeAction, Never> = .init()
    var doNodeActionPublisher: AnyPublisher<NodeAction, Never> {
        doNodeActionPassthrough.eraseToAnyPublisher()
    }
}
