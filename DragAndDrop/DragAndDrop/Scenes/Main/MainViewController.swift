//
//  MainViewController.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import Combine
import SpriteKit

// TODO LIST
/*
 Create stats screen showing how many items are in canvas
 Delete All button in stats screen
 OK add function in coordinator to show stats screen(modal)
 check triangle issue
 check memory management
 add physics
 unit tests
 ui tests
 refactor spriteKit things
 collection view to shapes?
 long tap to remove
 */

final class MainViewController: UIViewController {
    typealias ViewModelType = MainViewModel<MainCoordinator>
    var viewModel: ViewModelType!
    private var subscriptions: Set<AnyCancellable> = .init()
    private var currentNode: SKNode?

    private lazy var circleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .green
        button.setTitle("Circle", for: .normal)
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
        button.setTitle("Triangle", for: .normal)
        button.backgroundColor = .blue
        return button
    }()

    private lazy var squareButton: UIButton = {
        let button = UIButton()
        button.setTitle("Square", for: .normal)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureSubviews()
        configureSubscriptions()
        configureGameScene()
    }

    private func configureSubscriptions() {
        Publishers.Merge3(
            triangularButton.publisher(for: .touchUpInside).eraseToAnyPublisher(),
            squareButton.publisher(for: .touchUpInside).eraseToAnyPublisher(),
            circleButton.publisher(for: .touchUpInside).eraseToAnyPublisher())
            .sink { [weak self] button in
                guard let self = self else { return }
                var shape: Shape?
                switch button {
                case self.triangularButton:
                    shape = .triangle
                case self.circleButton:
                    shape = .circle
                case self.squareButton:
                    shape = .square
                default: break
                }
                guard let shape = shape else { return }
                self.viewModel.spawn(shape: shape)
            }
            .store(in: &subscriptions)

        undoButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.undoLastAction()
            }
            .store(in: &subscriptions)

        statsButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.statsButtonPressed()
            }
            .store(in: &subscriptions)
    }

    private func configureSubviews() {
        view.addSubview(triangularButton, anchors: [.top(100), .leading(20), .height(50), .width(80)])
        view.addSubview(circleButton, anchors: [.top(100), .centerX(0), .height(50), .width(80)])
        view.addSubview(squareButton, anchors: [.top(100), .trailing(-20), .height(50), .width(80)])
        view.addSubview(sceneView, anchors: [.centerX(0), .centerY(0), .height(sceneView.bounds.height), .width(sceneView.bounds.width)])
        view.addSubview(undoButton, anchors: [.trailing(-20), .width(50), .bottom(-20), .height(40)])
        view.addSubview(statsButton, anchors: [.bottom(-20), .centerX(0), .height(40), .width(100)])
    }

    private func configureGameScene() {
        let gameScene = GameScene(size: sceneView.bounds.size)
        gameScene.configure(with: self.viewModel.gameViewModel)
        sceneView.presentScene(gameScene)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let scene = sceneView.scene {
            let location = sceneView.convert(touch.location(in: sceneView), to: scene)
            let touchedNodes = scene.nodes(at: location)
            for node in touchedNodes.reversed() {
                    self.currentNode = node
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let node = currentNode, let scene = sceneView.scene {
            let touchLocation = sceneView.convert(touch.location(in: sceneView), to: scene)
            node.position = touchLocation
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let nodeName = self.currentNode?.name, let scene = sceneView.scene {
            let touchLocation = sceneView.convert(touch.location(in: sceneView), to: scene)
            self.viewModel.movedNode(previousX: Float(touchLocation.x), previousY: Float( touchLocation.y), uuid: nodeName)
        }
        self.currentNode = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentNode = nil
    }
}
