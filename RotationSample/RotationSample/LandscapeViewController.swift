//
//  LandscapeViewController.swift
//  RotationSample
//
//  Created by king on 2021/7/15.
//

import UIKit

protocol LandscapeViewControllerDelegate: AnyObject {
	func willRotateToOrientation(orientation: UIDeviceOrientation)
	func didRotateToOrientation(orientation: UIDeviceOrientation)
}

class LandscapeViewController: BaseViewController {
	var currentOrientation: UIDeviceOrientation = .portrait

	var contentView: PlayerContentView?
	var containerView: UIView?
	var targetRect: CGRect = .zero

	weak var delegate: LandscapeViewControllerDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		let newOrientation = UIDevice.current.orientation
		let oldOrientation = currentOrientation
		guard newOrientation.isValidInterfaceOrientation else {
			return
		}

		guard let containerView = containerView, let contentView = contentView else { return }

		if newOrientation.isLandscape, containerView.superview != view {
			view.addSubview(contentView)
		}

		let targetRect = self.targetRect

		if oldOrientation == .portrait {
			contentView.frame = targetRect
			contentView.setNeedsLayout()
			contentView.layoutIfNeeded()
		}

		currentOrientation = newOrientation

		let isFullScreen = size.width > size.height
		delegate?.willRotateToOrientation(orientation: newOrientation)
		coordinator.animate { _ in
			if isFullScreen {
				contentView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
			} else {
				contentView.frame = targetRect
			}
			contentView.setNeedsLayout()
			contentView.layoutIfNeeded()
		} completion: { [unowned self] _ in
			self.delegate?.didRotateToOrientation(orientation: newOrientation)
			if !isFullScreen {
				contentView.frame = containerView.bounds
				contentView.setNeedsLayout()
				contentView.layoutIfNeeded()
			}
		}
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		UIDevice.current.orientation.isLandscape ? .landscapeRight : .portrait
	}
}
