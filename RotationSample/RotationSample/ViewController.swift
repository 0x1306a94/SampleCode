//
//  ViewController.swift
//  RotationSample
//
//  Created by king on 2021/7/15.
//

// 参考自 ZFPlayer
// https://github.com/renzifeng/ZFPlayer/blob/master/ZFPlayer/Classes/Core/ZFOrientationObserver.m#L218

import UIKit

class ViewController: BaseViewController {
	var landscapeWindow: LandscapeWindow?

	var fullScreen = false

	var firstFlag = true

	@IBOutlet var containerView: UIView!
	lazy var contentView: PlayerContentView = {
		let v = PlayerContentView()
		return v
	}()

	var previousKeyWindow: UIWindow?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

		contentView.backgroundColor = .orange

		contentView.fullScreenButton.addTarget(self, action: #selector(switchFullScreen), for: .touchUpInside)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if firstFlag {
			firstFlag.toggle()
			containerView.addSubview(contentView)
			contentView.frame = containerView.bounds
		}
	}
}

extension ViewController {
	@objc
	func switchFullScreen() {
		fullScreen.toggle()
		if fullScreen {
			if landscapeWindow == nil {
				landscapeWindow = LandscapeWindow(frame: UIScreen.main.bounds)
				if #available(iOS 9.0, *) {
					landscapeWindow?.rootViewController?.loadViewIfNeeded()
				} else {
					_ = landscapeWindow?.rootViewController?.view
				}
			}

			landscapeWindow?.landscapeViewController.delegate = self
			landscapeWindow?.landscapeViewController.containerView = containerView
			landscapeWindow?.landscapeViewController.contentView = contentView
			landscapeWindow?.landscapeViewController.targetRect = contentView.convert(contentView.frame, to: containerView.window)

			let keyWindow = UIApplication.shared.keyWindow
			if keyWindow != landscapeWindow, keyWindow != previousKeyWindow {
				previousKeyWindow = UIApplication.shared.keyWindow
			}
			if !(landscapeWindow?.isKeyWindow ?? true) {
				landscapeWindow?.isHidden = true
				landscapeWindow?.makeKeyAndVisible()
			}
		} else {}
//		changeInterfaceOrientation(.unknown)
		changeInterfaceOrientation(fullScreen ? .landscapeRight : .portrait)
	}
}

extension ViewController: LandscapeViewControllerDelegate {
	func willRotateToOrientation(orientation: UIDeviceOrientation) {}

	func didRotateToOrientation(orientation: UIDeviceOrientation) {
		if orientation.isPortrait {
			containerView.addSubview(contentView)
			contentView.frame = containerView.bounds
			contentView.layoutIfNeeded()
			previousKeyWindow?.makeKeyAndVisible()
			previousKeyWindow = nil
			landscapeWindow?.isHidden = true
		}
	}
}
