//
//  NavigationController.swift
//  RotationSample
//
//  Created by king on 2021/7/15.
//

import UIKit

class NavigationController: UINavigationController {
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var shouldAutorotate: Bool {
		topViewController?.shouldAutorotate ?? true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		topViewController?.supportedInterfaceOrientations ?? .portrait
	}

	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
	}

	override var childForStatusBarStyle: UIViewController? {
		topViewController
	}

	override var childForHomeIndicatorAutoHidden: UIViewController? {
		topViewController
	}
}
