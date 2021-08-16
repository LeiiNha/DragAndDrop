//
//  GameScene.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 16/08/2021.
//

import SpriteKit
import Combine

final class GameScene: SKScene {
    private var nodes: [SKNode] = []
    private var subscriptions: Set<AnyCancellable> = .init()
    private let wait = SKAction.wait(forDuration: 0.3)

    var viewModel: GameSceneViewModelProtocol!
    func configure(with viewModel: GameSceneViewModelProtocol) {
        viewModel.doNodeActionPublisher
            .sink { [weak self] action in
                switch action {
                case .dragDrop:
                    break
                case .spawn(let shape, let uuid):
                    self?.spawnRandom(shape: shape, uuid: uuid)
                case .undoLastDragDrop(let log):
                    self?.undoLastDragDrop(log)
                case .removeLastSpawn:
                    self?.remove(node: self?.nodes.last)
                case .removeAll:
                    self?.removeAllChildren()
                case .longTapRemove(let uuid):
                    self?.remove(node: self?.nodes.first(where: { $0.name == uuid }))
                case .removeFirstSpawn:
                    self?.remove(node: self?.nodes.first)
                }
            }.store(in: &subscriptions)
    }

    private func undoLastDragDrop(_ log: DragDropLog) {
        guard let scene = scene else { return }
        let move = SKAction.move(to: .init(x: CGFloat(log.x), y: CGFloat(log.y)), duration: 0.25)
        let waitAndMove = SKAction.sequence([wait, move, wait])

        guard let lastNode = self.nodes.first(where: { $0.name == log.uuid }) else { return }
        let moveLastNode = SKAction.run { [weak lastNode] in
            lastNode?.run(waitAndMove)
        }
        scene.run(moveLastNode)
    }

    private func remove(node: SKNode?) {
        guard let scene = scene, let node = node else { return }
        let popOut = SKAction.scale(to: 0, duration: 0.25)
        let remove = SKAction.removeFromParent()
        let popOutAndRemove = SKAction.sequence([wait, popOut, remove])
        let removeNode = SKAction.run { [weak self] in
            guard let self = self else { return }
            node.run(popOutAndRemove)
            self.nodes.removeAll(where: { $0 == node })
        }
        scene.run(SKAction.sequence([removeNode, wait]))
    }

    private func spawnRandom(shape: Shape, uuid: String) {
        let popIn = SKAction.scale(to: 1, duration: 0.25)
        let popInAndOut = SKAction.sequence([popIn, wait])
        let node = shape.node(uuid: uuid)
        guard let scene = scene else { return }

        let addNode = SKAction.run {
            let popInArea = scene.frame
            node.position = popInArea.insetBy(dx: 25, dy: 25).randomPoint
            node.xScale = 0
            node.yScale = 0
            node.run(popInAndOut)
            scene.addChild(node)
        }

        scene.run(SKAction.sequence([addNode, wait]))
        self.nodes.append(node)
    }
}
