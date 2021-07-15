//
//  BaseViewController.swift
//  RotationSample
//
//  Created by king on 2021/7/15.
//

import UIKit

class BaseViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		view.backgroundColor = .white
	}

	override var shouldAutorotate: Bool {
		true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		.portrait
	}

	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		.portrait
	}
}

extension UIViewController {
	func changeInterfaceOrientation(_ orientation: UIDeviceOrientation) {
		let sel = NSSelectorFromString("setOrientation:")
		guard UIDevice.current.responds(to: sel) else {
			return
		}

		UIDevice.current.setValue(orientation.rawValue, forKeyPath: "orientation")
		UIViewController.attemptRotationToDeviceOrientation()
	}
}
