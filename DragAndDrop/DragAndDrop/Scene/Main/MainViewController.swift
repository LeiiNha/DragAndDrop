//
//  MainViewController.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import UIKit
import Combine
import SpriteKit

final class MainViewController: UIViewController {
    typealias ViewModelType = MainViewModel<MainCoordinator>
    var viewModel: ViewModelType!
    private var subscriptions: Set<AnyCancellable> = .init()
    private var currentNode: SKNode?
    private var nodes: [SKNode] = []

    private lazy var circleButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect()
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.backgroundColor = .green
        return button
    }()

    private lazy var undoButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemPink
        button.setTitle("Undo", for: .normal)
        return button
    }()

    private lazy var statsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Stats", for: .normal)
        return button
    }()

    private lazy var triangularButton: UIButton = {
        let button = UIButton()
        let heightWidth = 100
        let path = CGMutablePath()
        /*
         path.move(to: CGPoint(x: 0.0, y: 25.0))
         path.addLine(to: CGPoint(x: 25.0, y: -28.3))
         path.addLine(to: CGPoint(x: -25.0, y: -28.3))
         path.addLine(to: CGPoint(x: 0.0, y: 25.0))
         */

        path.move(to: CGPoint(x: 0, y: heightWidth))
        path.addLine(to: CGPoint(x:heightWidth/2, y: heightWidth/2))
        path.addLine(to: CGPoint(x:heightWidth, y:heightWidth))
        path.addLine(to: CGPoint(x:0, y:heightWidth))

        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor.blue.cgColor

        button.layer.insertSublayer(shape, at: 0)
        return button
    }()

    private lazy var squareButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        return button
    }()

    private lazy var sceneView: SKView = {
        let view = SKView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 40, height: self.view.bounds.width - 40))
        view.backgroundColor = .clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()

    private lazy var scene: SKScene = {
        let scene = SKScene(size: sceneView.frame.size)
        scene.backgroundColor = .clear
        return scene
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureSubviews()
        configureSubscriptions()
    }

    private func configureSubscriptions() {
        triangularButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.spawnRandom(shape: .triangle)
                self?.viewModel.pressed(shape: .triangle)
            }
            .store(in: &subscriptions)
        
        squareButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.spawnRandom(shape: .square)
                self?.viewModel.pressed(shape: .square)
            }
            .store(in: &subscriptions)

        circleButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.spawnRandom(shape: .circle)
                self?.viewModel.pressed(shape: .circle)
            }
            .store(in: &subscriptions)

        undoButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.undoLastAction()
            }
            .store(in: &subscriptions)

        viewModel.removeLastNodePublisher
            .sink { [weak self] _ in
                self?.removeLastNode()
            }
            .store(in: &subscriptions)

        statsButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.statsButtonPressed()
            }
            .store(in: &subscriptions)
    }

    private func configureSubviews() {
        view.addSubview(triangularButton, anchors: [.top(100), .leading(20), .height(50), .width(50)])
        view.addSubview(circleButton, anchors: [.top(100), .centerX(0), .height(50), .width(50)])
        view.addSubview(squareButton, anchors: [.top(100), .trailing(-20), .height(50), .width(50)])
        view.addSubview(sceneView, anchors: [.centerX(0), .centerY(0), .height(sceneView.bounds.height), .width(sceneView.bounds.width)])
        sceneView.presentScene(scene)
        view.addSubview(undoButton, anchors: [.trailing(-20), .width(50), .bottom(-20), .height(40)])
        view.addSubview(statsButton, anchors: [.bottom(-20), .centerX(0), .height(40), .width(100)])
    }

    private func removeLastNode() {
        let wait = SKAction.wait(forDuration: 0.1)
        let popOut = SKAction.scale(to: 0, duration: 0.25)
        let remove = SKAction.removeFromParent()
        let popOutAndRemove = SKAction.sequence([wait, popOut, remove])
        let removeLastNode = SKAction.run { [weak self] in
            guard let self = self, let lastNode = self.nodes.last else { return }
            lastNode.run(popOutAndRemove)
            self.nodes.removeLast()
        }
        scene.run(SKAction.sequence([removeLastNode, wait]))
    }

    private func getSquareNode() -> SKShapeNode {
        let square = SKShapeNode(rectOf: .init(width: 50, height: 50))
        square.fillColor = .red
        return square
    }

    private func getTriangleNode() -> SKShapeNode {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 25.0))
        path.addLine(to: CGPoint(x: 25.0, y: -28.3))
        path.addLine(to: CGPoint(x: -25.0, y: -28.3))
        path.addLine(to: CGPoint(x: 0.0, y: 25.0))
        let triangle = SKShapeNode(path: path.cgPath)
        triangle.fillColor = .blue
        return triangle
    }

    private func getCircleNode() -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: 25)
        node.fillColor = .green
        return node
    }

    private func spawnRandom(shape: Shape) {
        let wait = SKAction.wait(forDuration: 0.5)
        let popIn = SKAction.scale(to: 1, duration: 0.25)
        let popInAndOut = SKAction.sequence([popIn, wait])

        let addNode = SKAction.run { [weak self] in
            guard let self = self else { return }
            let node: SKShapeNode
            switch shape {
            case .circle:
                node = self.getCircleNode()
            case .triangle:
                node = self.getTriangleNode()
            case .square:
                node = self.getSquareNode()
            }
            let popInArea = self.scene.frame
            node.position = popInArea.insetBy(dx: 25, dy: 25).randomPoint
            node.xScale = 0
            node.yScale = 0
            node.run(popInAndOut)
            self.scene.addChild(node)
            self.nodes.append(node)
        }

        scene.run(SKAction.sequence([addNode, wait]))
        //scene.run(SKAction.repeatForever(SKAction.sequence([addBall, wait])))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = sceneView.convert(touch.location(in: sceneView), to: scene)
            let touchedNodes = self.scene.nodes(at: location)
            for node in touchedNodes.reversed() {
                    self.currentNode = node
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let node = currentNode {
            let touchLocation = sceneView.convert(touch.location(in: sceneView), to: scene)
            node.position = touchLocation
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentNode = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentNode = nil
    }
}

public extension CGFloat {
    static var random: CGFloat { return CGFloat(arc4random()) / CGFloat(UInt32.max) }

    static func random(between x: CGFloat, and y: CGFloat) -> CGFloat {
        let (start, end) = x < y ? (x, y) : (y, x)
        return start + CGFloat.random * (end - start)
    }
}

public extension CGRect {
    var randomPoint: CGPoint {
        var point = CGPoint()
        point.x = CGFloat.random(between: origin.x, and: origin.x + width)
        point.y = CGFloat.random(between: origin.y, and: origin.y + height)
        return point
    }
}
