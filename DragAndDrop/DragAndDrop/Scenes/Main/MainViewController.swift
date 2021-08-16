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
 OK Create stats screen showing how many items are in canvas
 OK Delete All button in stats screen
 OK add function in coordinator to show stats screen(modal)
 OK check memory management
 OK refactor spriteKit things
 OK long tap to remove
 OK Swipe to delete in stats screen
 OK collection view to shapes

 unit tests
 ui tests
 add physics
 */

final class MainViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Shape>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Shape>
    typealias ViewModelType = MainViewModel<MainCoordinator>

    var viewModel: ViewModelType!
    private var subscriptions: Set<AnyCancellable> = .init()
    private var currentNode: SKNode?
    private var dataSource: DataSource?
    private var collectionView: UICollectionView?

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

    private lazy var sceneView: SKView = {
        let view = SKView(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 40, height: view.bounds.width - 40))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureCollectionView()
        configureDataSource()
        configureSubviews()
        configureSubscriptions()
        configureGameScene()
        configureLongTap()
    }

    private func configureLongTap() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        view.addGestureRecognizer(longPressRecognizer)
    }

    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        guard let scene = sceneView.scene else { return }
        let location = sceneView.convert(sender.location(in: sceneView), to: scene)
        if let touchedNodeName = scene.nodes(at: location).first?.name {
            viewModel.removeNode(uuid: touchedNodeName)
        }
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: Section.buttons.layout)
        guard let collectionView = collectionView else { return }
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier:  MainCollectionViewCell.identifier)
        view.addSubview(collectionView)
    }

    private func configureDataSource() {
        guard let collectionView = collectionView else { return }
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> MainCollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  MainCollectionViewCell.identifier, for: indexPath) as? MainCollectionViewCell
            cell?.configure(shape: item)
            return cell
        })

        var snapshot = DataSourceSnapshot()
        snapshot.appendSections([Section.buttons])
        snapshot.appendItems(Shape.allCases)

        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func configureSubscriptions() {
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
        if let collectionView = collectionView {
            view.addSubview(collectionView, anchors: [.top(100), .height(200), .leading(20), .trailing(-20)])
        }
        view.addSubview(sceneView, anchors: [.centerX(0), .centerY(0), .height(sceneView.bounds.height), .width(sceneView.bounds.width)])
        view.addSubview(undoButton, anchors: [.trailing(-20), .width(50), .bottom(-20), .height(40)])
        view.addSubview(statsButton, anchors: [.bottom(-20), .centerX(0), .height(40), .width(100)])
    }

    private func configureGameScene() {
        let gameScene = GameScene(size: sceneView.bounds.size)
        gameScene.configure(with: viewModel.gameViewModel)
        sceneView.presentScene(gameScene)
    }
}

// MARK: -CollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let shape = dataSource?.itemIdentifier(for: indexPath),
              let scene = sceneView.scene else { return }
        let popInArea = scene.frame
        let position = popInArea.insetBy(dx: 25, dy: 25).randomPoint
        viewModel.spawn(shape: shape, spawnedX: Float(position.x), spawnedY: Float(position.y))
    }
}

// MARK: -Touch Events
extension MainViewController {
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
        if let touch = touches.first, let nodeName = currentNode?.name, let scene = sceneView.scene {
            let touchLocation = sceneView.convert(touch.location(in: sceneView), to: scene)
            viewModel.movedNode(previousX: Float(touchLocation.x), previousY: Float( touchLocation.y), uuid: nodeName)
        }
        currentNode = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentNode = nil
    }
}

// MARK: -Section
extension MainViewController {
    enum Section: CaseIterable {
        case buttons
        var layout: UICollectionViewLayout {
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 8, bottom: 8, trailing: 8)

            let group = NSCollectionLayoutGroup.horizontal(layoutSize:  groupSize, subitems: [item])
            group.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
            let section = NSCollectionLayoutSection(group: group)


            return UICollectionViewCompositionalLayout(section: section)
        }
        var groupSize: NSCollectionLayoutSize { .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.2)) }

        var itemSize: NSCollectionLayoutSize { .init(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1)) }
    }
}
