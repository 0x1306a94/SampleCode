//
//  PlayerContentView.swift
//  RotationSample
//
//  Created by king on 2021/7/15.
//

import UIKit

class PlayerContentView: UIView {
	lazy var fullScreenButton: UIButton = {
		let button = UIButton(type: .custom)
		button.setTitle("切换全屏", for: .normal)
		return button
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(fullScreenButton)
		fullScreenButton.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			fullScreenButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
			fullScreenButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
