//
//  StartupViewController.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import UIKit

final class StartupViewController: UIViewController {
    typealias ViewModelType = StartupViewModelProtocol

    var viewModel: ViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.showRootController()
    }
}
