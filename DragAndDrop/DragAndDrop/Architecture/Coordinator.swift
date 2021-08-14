//
//  Coordinator.swift
//  DragAndDrop
//
//  Created by Erica Geraldes on 14/08/2021.
//

import UIKit
import Combine

public protocol Coordinator {
    associatedtype ViewController: UIViewController
    var weakViewController: WeakReference<ViewController> { get }

    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)

    func dismiss(animated: Bool, completion: (() -> Void)?)

    func dismissPresentedViewController(animated: Bool, completion: (() -> Void)?)
}

public extension Coordinator {
    var viewController: ViewController? {
        weakViewController.object
    }

    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        viewController?.present(viewControllerToPresent, animated: animated, completion: completion)
    }

    func present(_ viewControllerToPresent: UIViewController) {
        present(viewControllerToPresent, animated: true, completion: nil)
    }

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        viewController?.presentingViewController?.dismiss(animated: animated, completion: completion)
    }

    func dismissPresentedViewController(animated: Bool = true) {
        dismissPresentedViewController(animated: animated, completion: nil)
    }

    func dismissPresentedViewController(animated: Bool, completion: (() -> Void)?) {
        guard viewController?.presentedViewController?.isBeingDismissed == false else {
            completion?()
            return
        }
        viewController?.dismiss(animated: animated, completion: completion)
    }

    func dismiss(animated: Bool = true) {
        dismiss(animated: animated, completion: nil)
    }

    func pushViewController(_ newViewController: UIViewController, animated: Bool, title: String? = nil) {
        viewController?.navigationController?.pushViewController(newViewController, animated: animated)
        viewController?.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func popViewController(animated: Bool) {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func popToRootViewController(animated: Bool) {
        viewController?.navigationController?.popToRootViewController(animated: true)
    }
}

public protocol ApplicationCoordinator: Coordinator {
    func start(in window: UIWindow)
}

extension Coordinator {
    func showInModalContext(_ vc: UIViewController, animated: Bool = true, sender: Any? = nil) {
        guard let presentingViewController = viewController else { return }
        guard presentingViewController.isModal else {
            let navController = UINavigationController(rootViewController: presentingViewController)
            presentingViewController.present(navController, animated: animated)
            return
        }
        presentingViewController.show(vc, sender: sender)
    }
}

extension UIViewController {
    var isModal: Bool {
        let parentIsModal = parent?.isModal
        return presentingViewController != nil && parentIsModal != false
    }
}

protocol DefaultCoordinatorProtocol: Coordinator {
    func popViewController(animated: Bool)
    var didSubmitPublisher: AnyPublisher<Void, Never> { get }
    func didSubmit()
}
struct DefaultCoordinator: DefaultCoordinatorProtocol {
    let weakViewController: WeakReference<UIViewController>
    private let didSubmitSubject: PassthroughSubject<Void, Never> = .init()

    func popViewController(animated: Bool) {
        weakViewController.object?.navigationController?.popViewController(animated: animated)
    }

    var didSubmitPublisher: AnyPublisher<Void, Never> {
        didSubmitSubject.eraseToAnyPublisher()
    }

    func didSubmit() {
        didSubmitSubject.send()
    }
}

protocol CoordinatedViewModel: ViewModel {
    associatedtype CoordinatorType: Coordinator

    var coordinator: CoordinatorType { get }
}

public protocol ViewModel {}

public protocol ReferenceViewModel: AnyObject, ViewModel {}
