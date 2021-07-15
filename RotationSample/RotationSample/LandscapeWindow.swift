//
//  LandscapeWindow.swift
//  RotationSample
//
//  Created by king on 2021/7/15.
//

import UIKit

class LandscapeWindow: UIWindow {
	private(set) var landscapeViewController: LandscapeViewController!

	static var Bounds = CGRect.zero
	override init(frame: CGRect) {
		super.init(frame: frame)
		windowLevel = .normal
		landscapeViewController = LandscapeViewController()
		rootViewController = landscapeViewController
		if #available(iOS 13.0, *) {
			if windowScene == nil {
				windowScene = UIApplication.shared.windows.first { $0.isKeyWindow }?.windowScene
			}
		}

		isHidden = true
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

//	override func layoutSubviews() {
//		super.layoutSubviews()
//
//		if !LandscapeWindow.Bounds.equalTo(bounds) {}
//		LandscapeWindow.Bounds = bounds
//
//		rootViewController?.view.frame = bounds
//	}
}
