//
//  CustomTabBar.swift
//  CustomTabBarSample
//
//  Created by king on 2024/9/14.
//

import UIKit

class CustomTabBarButton: UIButton {
    weak var originButton: UIControl?
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else {
            return nil
        }
        if let originButton, hitView == self {
            return originButton
        }
        return hitView
    }
}

class CustomTabBar: UITabBar {
    let customContentView: UIView = .init()
    let customButtonStackView: UIStackView = .init()
    private var originButtons: [UIControl] = []

    static let MinimumHeight: CGFloat = 58.0 + 20.0
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCustom()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCustom()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = fmax(Self.MinimumHeight, size.height)
        return size
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if let _ = window, originButtons.isEmpty {
            self.originButtons = self.subviews.compactMap { $0 as? UIControl }
            self.subviews.forEach { $0.isHidden = $0 != self.customContentView }
            self.addCustomButtons()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

private extension CustomTabBar {
    func setupCustom() {
        self.customContentView.backgroundColor = UIColor(named: "tabbar_background_color")
        self.customContentView.layer.cornerRadius = 28
        self.customContentView.layer.borderColor = UIColor.white.cgColor
        self.customContentView.layer.borderWidth = 1.0
        self.customContentView.translatesAutoresizingMaskIntoConstraints = false

        self.customButtonStackView.spacing = 10
        self.customButtonStackView.axis = .horizontal
        self.customButtonStackView.distribution = .fillProportionally
        self.customButtonStackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.customContentView)
        self.customContentView.addSubview(self.customButtonStackView)

        NSLayoutConstraint.activate([
            self.customContentView.widthAnchor.constraint(equalToConstant: 300),
            self.customContentView.heightAnchor.constraint(equalToConstant: 58),
            self.customContentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.customContentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            self.customButtonStackView.topAnchor.constraint(equalTo: self.customContentView.topAnchor),
            self.customButtonStackView.bottomAnchor.constraint(equalTo: self.customContentView.bottomAnchor),
            self.customButtonStackView.centerXAnchor.constraint(equalTo: self.customContentView.centerXAnchor),
        ])
    }

    func addCustomButtons() {
        for item in self.originButtons {
            let button = CustomTabBarButton()
            button.originButton = item
            button.backgroundColor = .brown
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 45),
            ])
            self.customButtonStackView.addArrangedSubview(button)
        }
    }
}
