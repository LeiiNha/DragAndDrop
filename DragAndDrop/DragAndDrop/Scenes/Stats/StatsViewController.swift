//
//  StatsViewController.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 15/08/2021.
//

import UIKit

final class StatsViewController: UIViewController {
    typealias ViewModelType = StatsViewModel<DefaultCoordinator>
    var viewModel: ViewModelType!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureSubviews()
    }

    private func configureSubviews() {
        view.addSubview(triangleCount, anchors: [.top(100), .leading(15), .trailing(-15)])
        view.addSubview(squareCount, anchors: [.top(150), .leading(15), .trailing(-15)])
        view.addSubview(circleCount, anchors: [.top(200), .leading(15), .trailing(-15)])
    }
}
