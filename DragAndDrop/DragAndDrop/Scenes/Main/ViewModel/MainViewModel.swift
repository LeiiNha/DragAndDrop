//
//  MainViewModel.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import Foundation
import Combine

protocol MainViewModelProtocol {
    func undoLastAction()
    func statsButtonPressed()
    func movedNode(previousX: Float, previousY: Float, uuid: String)
    func spawn(shape: Shape)
    func removeNode(uuid: String)
}

final class MainViewModel<CoordinatorType: MainCoordinatorProtocol>: CoordinatedViewModel, MainViewModelProtocol {
    let coordinator: CoordinatorType
    private var subscriptions: Set<AnyCancellable> = .init()
    private let nodesLimit: Int = 20
    private var actionsLog: [NodeAction] = []
    let gameViewModel: GameSceneViewModelProtocol

    init(coordinator: CoordinatorType, gameViewModel: GameSceneViewModelProtocol) {
        self.coordinator = coordinator
        self.gameViewModel = gameViewModel
    }

    func statsButtonPressed() {
        let statsViewModel = coordinator.showStats(logs: actionsLog)
        statsViewModel.removeShapesPublisher
            .sink { [weak self] shapes in
                let action = NodeAction.removeAll(shapes: shapes)
                self?.actionsLog.removeAll()
                self?.gameViewModel.doNodeAction(nodeAction: action)
                self?.actionsLog.append(action)
            }.store(in: &subscriptions)
    }

    func spawn(shape: Shape) {
        let countSpawnedShapes = actionsLog.filter { log in
            guard case .spawn = log else { return false }
            return true
        }.count
        if countSpawnedShapes >= nodesLimit {
            let action = NodeAction.removeFirstSpawn
            gameViewModel.doNodeAction(nodeAction: action)
            let firstSpawnLog = actionsLog.enumerated().first(where: {
                if case .spawn = $0.element { return true }
                return false
            })
            actionsLog.append(action)
            guard let offset = firstSpawnLog?.offset else { return }
            actionsLog.remove(at: offset)

        }
        let action = NodeAction.spawn(shape: shape, uuid: UUID().uuidString)
        gameViewModel.doNodeAction(nodeAction: action)
        actionsLog.append(action)
    }

    func removeNode(uuid: String) {
        let action = NodeAction.longTapRemove(uuid: uuid)
        gameViewModel.doNodeAction(nodeAction: action)
        actionsLog.append(action)
    }

    func undoLastAction() {
        guard let lastAction = actionsLog.enumerated().filter({ index, log in
            if case .spawn = log  { return true }
            else if case .dragDrop = log { return true }

            return false
        }).last else { return }

        switch lastAction.element {
        case .dragDrop(let log):
            gameViewModel.doNodeAction(nodeAction: .undoLastDragDrop(log: log))
            self.actionsLog.remove(at: lastAction.offset)
        case .spawn:
            gameViewModel.doNodeAction(nodeAction: .removeLastSpawn)
            self.actionsLog.remove(at: lastAction.offset)
        case .removeAll: break
        case .longTapRemove: break
        case .undoLastDragDrop: break
        case .removeLastSpawn: break
        case .removeFirstSpawn: break
        }
    }

    func movedNode(previousX: Float, previousY: Float, uuid: String) {
        let action = NodeAction.dragDrop(log: .init(x: previousX, y: previousY, uuid: uuid))
        gameViewModel.doNodeAction(nodeAction: action)
        actionsLog.append(action)
    }
}
