//
//  MainViewModel.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import Foundation
import CoreBluetooth
import Combine

protocol MainViewModelProtocol {
    func pressed(shape: Shape)
    func undoLastAction()
    func statsButtonPressed()
    var removeLastNodePublisher: AnyPublisher<Void, Never> { get }
}

final class MainViewModel<CoordinatorType: MainCoordinatorProtocol>: CoordinatedViewModel, MainViewModelProtocol {
    let coordinator: CoordinatorType
    private var subscriptions: Set<AnyCancellable> = .init()

    private var actionsLog: [Action] = []

    init(coordinator: CoordinatorType) {
        self.coordinator = coordinator
    }

    private var removeLastNodePassthrough: PassthroughSubject<Void, Never> = .init()
    var removeLastNodePublisher: AnyPublisher<Void, Never> {
        removeLastNodePassthrough.eraseToAnyPublisher()
    }

    func statsButtonPressed() {
        // coordinator.showStats()
    }

    func undoLastAction() {
        guard let lastAction = actionsLog.last else { return }
        switch lastAction {
        case .dragDrop: break
        case .longTapRemove: break
        case .pressed(_):
            removeLastNodePassthrough.send()
        case .removeAll: break
        case .undo: break
        }
    }

    func pressed(shape: Shape) {
        switch shape {
        case .circle:
            print("pressed circle")
            actionsLog.append(.pressed(shape: .circle))
        case .square:
            print("pressed square")
            actionsLog.append(.pressed(shape: .square))
        case .triangle:
            print("pressed triangle")
            actionsLog.append(.pressed(shape: .triangle))
        }
    }
}
