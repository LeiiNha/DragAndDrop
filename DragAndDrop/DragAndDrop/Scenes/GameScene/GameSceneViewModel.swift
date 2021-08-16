//
//  GameSceneViewModel.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 16/08/2021.
//

import Foundation
import Combine

protocol GameSceneViewModelProtocol {
    func doNodeAction(nodeAction: NodeAction)
    var doNodeActionPublisher: AnyPublisher<NodeAction, Never> { get }
}

final class GameSceneViewModel: GameSceneViewModelProtocol {
    
    private var doNodeActionPassthrough: PassthroughSubject<NodeAction, Never> = .init()
    var doNodeActionPublisher: AnyPublisher<NodeAction, Never> {
        doNodeActionPassthrough.eraseToAnyPublisher()
    }

    func doNodeAction(nodeAction: NodeAction) {
        doNodeActionPassthrough.send(nodeAction)
    }
}
