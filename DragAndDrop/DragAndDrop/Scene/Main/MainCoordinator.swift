//
//  MainCoordinator.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import Foundation
import UIKit

protocol MainCoordinatorProtocol: Coordinator {
    func showStats()
}

struct MainCoordinator: MainCoordinatorProtocol {
    let weakViewController: WeakReference<UIViewController>
    func showStats() {

    }
}
