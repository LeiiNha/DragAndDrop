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
    func spawn(shape: Shape, spawnedX: Float, spawnedY: Float)
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

    func spawn(shape: Shape, spawnedX: Float, spawnedY: Float) {
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
        let action = NodeAction.spawn(shape: shape, log: .init(x: spawnedX, y: spawnedY, uuid: UUID().uuidString))
        gameViewModel.doNodeAction(nodeAction: action)
        actionsLog.append(action)
    }

    func removeNode(uuid: String) {
        let action = NodeAction.longTapRemove(uuid: uuid)
        gameViewModel.doNodeAction(nodeAction: action)
        actionsLog.append(action)
    }

    func undoLastAction() {
        let lastActions = actionsLog.enumerated().filter({ index, log in
            if case .spawn = log  { return true }
            else if case .dragDrop = log { return true }

            return false
        })

        guard let lastAction = lastActions.last else { return }

        switch lastAction.element {
        case .dragDrop(let lastDragDrop):
            let nodeUUID = lastDragDrop.uuid
            var positions: [NodePosition] = []
            
            lastActions.forEach { item in
                if case .spawn(_, let firstLog) = item.element,
                   firstLog.uuid == nodeUUID {
                    positions.insert(firstLog, at: 0)
                    return
                }
                if case .dragDrop(let log) = item.element,
                   log.uuid == nodeUUID {
                    positions.append(log)
                    return
                }
            }
            // Last position is the current node position
            positions.removeLast()

            if let lastPosition = positions.last {
                gameViewModel.doNodeAction(nodeAction: .undoLastDragDrop(log: lastPosition))
                actionsLog.remove(at: lastAction.offset)
                return
            }

        case .spawn:
            gameViewModel.doNodeAction(nodeAction: .removeLastSpawn)
            actionsLog.remove(at: lastAction.offset)
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
