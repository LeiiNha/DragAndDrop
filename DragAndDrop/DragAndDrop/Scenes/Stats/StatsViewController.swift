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
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(StatsTableViewCell.self,
                           forCellReuseIdentifier: StatsTableViewCell.identifier)
        tableView.delegate = self
        return tableView
    }()

    private lazy var dataSource: StatsDataSource? = {
        return StatsDataSource(tableView: tableView) {  tableView, indexPath, stat in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: StatsTableViewCell.identifier,
                                                               for: indexPath)
                        as? StatsTableViewCell else { return  UITableViewCell() }

                cell.configure(name: stat.text, count: stat.count)
                return cell
            }
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
        configureTableView()
        configureSubviews()
        configureSubscriptions()
        updateSnapshot(with: viewModel.statsDetails)
    }

    private func configureTableView() {
        tableView.dataSource = dataSource
    }

    private func updateSnapshot(with stats: [StatsDetails]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, StatsDetails>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(stats, toSection: .stats)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func configureSubscriptions() {
        removeAllButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.removeShapes(shapes: Shape.allCases)
            }.store(in: &subscriptions)
    }

    private func configureSubviews() {
        view.addSubview(removeAllButton, anchors: [.bottom(-50), .centerX(0), .height(50), .width(150)])
        view.addSubview(tableView, anchors: [.top(100), .leading(15), .trailing(-15), .height(300)])

    }
}

extension StatsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       let lockedAction = UIContextualAction(style: .normal, title: "Remove") { [weak self] (_, _, completion) in
        guard let item = self?.dataSource?.itemIdentifier(for: indexPath) else { return }
        self?.viewModel.removeShapes(shapes: [item.shape])
           completion(true)
       }

        return UISwipeActionsConfiguration(actions: [lockedAction])
    }
}

final class StatsDataSource: UITableViewDiffableDataSource<StatsViewController.Section,
                                                StatsViewController.StatsDetails> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension StatsViewController {
    enum Section: CaseIterable {
        case stats
    }

    struct StatsDetails: Hashable {
        var text: String { shape.text }
        var count: Int
        let shape: Shape
    }
}
