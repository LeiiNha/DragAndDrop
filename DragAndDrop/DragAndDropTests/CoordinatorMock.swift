//
//  CoordinatorMock.swift
//  DragAndDropTests
//
//  Created by Erica Geraldes on 16/08/2021.
//

import UIKit
@testable import DragAndDrop
import Combine

final class CoordinatorMock: Coordinator, Mock {
    typealias ViewController = UIViewController
    var weakViewController: WeakReference<UIViewController> = .init()
    private var didSubmitPassthrough: PassthroughSubject<Void, Never> = .init()

    typealias Method = Function
    var callersCount: [Function : Int]
    init() {
        self.callersCount = .init()
    }

    enum Function: Hashable, CaseIterable {
        case showStatScreen
        case didSubmit
    }
}

extension CoordinatorMock: DefaultCoordinatorProtocol {
    var didSubmitPublisher: AnyPublisher<Void, Never> {
        didSubmitPassthrough.eraseToAnyPublisher()
    }

    func didSubmit() {
        incrementCounterFor(.didSubmit)
    }
}

extension CoordinatorMock: MainCoordinatorProtocol {
    func showStats(logs: [NodeAction]) -> StatsViewModelProtocol {
        incrementCounterFor(.showStatScreen)
        return StatsViewModel(coordinator: CoordinatorMock(), logs: [])
    }
}
