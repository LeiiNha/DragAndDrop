//
//  GameScene.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 16/08/2021.
//

import SpriteKit
import Combine

final class GameScene: SKScene {
    private var nodeShape: [NodeShape] = []
    private var subscriptions: Set<AnyCancellable> = .init()
    private let wait = SKAction.wait(forDuration: 0.3)

    var viewModel: GameSceneViewModelProtocol!
    func configure(with viewModel: GameSceneViewModelProtocol) {
        viewModel.doNodeActionPublisher
            .sink { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .dragDrop:
                    break
                case .spawn(let shape, let log):
                    self.spawnRandom(shape: shape,
                                     uuid: log.uuid,
                                     position: .init(x: CGFloat(log.x), y: CGFloat(log.y)))
                case .undoLastDragDrop(let log):
                    self.undoLastDragDrop(log)
                case .removeLastSpawn:
                    self.remove(node: self.nodeShape.last?.node)
                case let .removeAll(shapes):
                    guard shapes == Shape.allCases else {
                        let nodesToRemove = self.nodeShape.compactMap { item -> SKNode? in
                            if shapes.contains(item.shape) { return item.node }
                            return nil
                        }
                        self.removeChildren(in: nodesToRemove)
                        return
                    }
                    self.removeAllChildren()

                case .longTapRemove(let uuid):
                    self.remove(node: self.nodeShape.first(where: { $0.node.name == uuid })?.node)
                case .removeFirstSpawn:
                    self.remove(node: self.nodeShape.first?.node)
                }
            }.store(in: &subscriptions)
    }

    private func undoLastDragDrop(_ log: NodePosition) {
        guard let scene = scene else { return }

        let move = SKAction.move(to: .init(x: CGFloat(log.x), y: CGFloat(log.y)), duration: 0.25)
        let moveAndWait = SKAction.sequence([move, wait])
        scene.isPaused = false
        guard let lastMovedNode = nodeShape.first(where: { $0.node.name == log.uuid })?.node else { return }
        lastMovedNode.run(moveAndWait)
    }

    private func remove(node: SKNode?) {
        guard let scene = scene, let node = node else { return }
        let popOut = SKAction.scale(to: 0, duration: 0.25)
        let remove = SKAction.removeFromParent()
        let popOutAndRemove = SKAction.sequence([wait, popOut, remove])
        let removeNode = SKAction.run { [weak self] in
            guard let self = self else { return }
            node.run(popOutAndRemove)
            self.nodeShape.removeAll(where: { $0.node == node })
        }
        scene.run(SKAction.sequence([removeNode, wait]))
    }

    private func spawnRandom(shape: Shape, uuid: String, position: CGPoint) {
        let popIn = SKAction.scale(to: 1, duration: 0.25)
        let popInAndOut = SKAction.sequence([popIn, wait])
        let node = shape.node(uuid: uuid)
        guard let scene = scene else { return }

        let addNode = SKAction.run {
            node.position = position
            node.xScale = 0
            node.yScale = 0
            node.run(popInAndOut)
            scene.addChild(node)
        }

        scene.run(SKAction.sequence([addNode, wait]))
        nodeShape.append(.init(node: node, shape: shape))
    }
}

struct NodeShape {
    let node: SKNode
    let shape: Shape
}
