//
//  TabBarController.swift
//  RotationSample
//
//  Created by king on 2021/7/15.
//

import UIKit

class TabBarController: UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var shouldAutorotate: Bool {
		selectedViewController?.shouldAutorotate ?? true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		selectedViewController?.supportedInterfaceOrientations ?? .portrait
	}

	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		selectedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
	}

	override var childForStatusBarStyle: UIViewController? {
		selectedViewController
	}

	override var childForHomeIndicatorAutoHidden: UIViewController? {
		selectedViewController
	}
}
