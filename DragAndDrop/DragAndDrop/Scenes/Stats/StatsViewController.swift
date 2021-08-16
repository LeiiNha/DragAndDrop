//
//  StatsViewController.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 15/08/2021.
//

import UIKit
import Combine

final class StatsViewController: UIViewController {
    typealias ViewModelType = StatsViewModel<DefaultCoordinator>
    var viewModel: ViewModelType!
    private var subscriptions: Set<AnyCancellable> = .init()

    private lazy var triangleCount: UILabel = {
        let label = UILabel()
        label.text = "Triangle count: " + self.viewModel.triangleCount.description
        return label
    }()

    private lazy var circleCount: UILabel = {
        let label = UILabel()
        label.text = "Circle count: " + self.viewModel.circleCount.description
        return label
    }()

    private lazy var squareCount: UILabel = {
        let label = UILabel()
        label.text = "Square count: " + self.viewModel.squareCount.description
        return label
    }()

    private lazy var removeAllButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Remove All", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureSubviews()
        configureSubscriptions()
    }

    private func configureSubscriptions() {
        removeAllButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.removeAllPressed()
            }.store(in: &subscriptions)
    }

    private func configureSubviews() {
        view.addSubview(triangleCount, anchors: [.top(100), .leading(15), .trailing(-15)])
        view.addSubview(squareCount, anchors: [.top(150), .leading(15), .trailing(-15)])
        view.addSubview(circleCount, anchors: [.top(200), .leading(15), .trailing(-15)])
        view.addSubview(removeAllButton, anchors: [.centerY(0), .centerX(0), .height(50), .width(150)])
    }
}
