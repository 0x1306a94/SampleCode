//
//  ViewController.swift
//  ChildViewControllerTransition
//
//  Created by king on 2021/5/8.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet var buttonContainerView: UIView!
	lazy var firstVC = FirstViewController()
	lazy var secondVC = SecondViewController()
	lazy var thirdVC = ThirdViewController()

	var currentViewController: UIViewController!

	var activateConstraints: [NSLayoutConstraint] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		print("\(type(of: self)) \(#function)")

		currentViewController = firstVC
		addChild(firstVC)
//		addChild(secondVC)
//		addChild(thirdVC)
		view.addSubview(firstVC.view)
		firstVC.view.translatesAutoresizingMaskIntoConstraints = false

		activateConstraints = [
			firstVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			firstVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			firstVC.view.topAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
			firstVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
		]
		NSLayoutConstraint.activate(activateConstraints)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		print("\(type(of: self)) \(#function)")
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		print("\(type(of: self)) \(#function)")
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		print("\(type(of: self)) \(#function)")
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		print("\(type(of: self)) \(#function)")
	}

	@IBAction func firstButtonAction(_ sender: UIButton) {
		guard currentViewController != firstVC else {
			return
		}
		switchToViewController(controller: firstVC)
	}

	@IBAction func secondButtonAction(_ sender: UIButton) {
		guard currentViewController != secondVC else {
			return
		}
		switchToViewController(controller: secondVC)
	}

	@IBAction func thirdButtonAction(_ sender: UIButton) {
		guard currentViewController != thirdVC else {
			return
		}

		switchToViewController(controller: thirdVC)
	}

	@IBAction func presentButtonAction(_ sender: UIButton) {
		let vc = FourthViewController()
		vc.modalPresentationStyle = .fullScreen

		present(vc, animated: true, completion: nil)
	}

	func switchToViewController(controller: UIViewController) {
		addChild(controller)
		let oldVC = currentViewController

		let options: UIView.AnimationOptions = [.layoutSubviews, .allowUserInteraction, .transitionCrossDissolve]

		transition(from: currentViewController, to: controller, duration: 0.25, options: options) {} completion: { [unowned self] in
			guard $0 else {
				self.currentViewController = oldVC
				return
			}
			controller.didMove(toParent: self)
			currentViewController.willMove(toParent: nil)
//			NSLayoutConstraint.deactivate(activateConstraints)
			currentViewController.view.removeFromSuperview()
			currentViewController.removeFromParent()

			currentViewController = controller
			let toView = currentViewController.view!

			self.view.addSubview(toView)
			toView.translatesAutoresizingMaskIntoConstraints = false

			activateConstraints = [
				toView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
				toView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
				toView.topAnchor.constraint(equalTo: self.buttonContainerView.bottomAnchor),
				toView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
			]
			NSLayoutConstraint.activate(activateConstraints)
		}
	}
}
