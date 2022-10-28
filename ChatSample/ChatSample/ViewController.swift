//
//  ViewController.swift
//  ChatSample
//
//  Created by king on 2022/10/28.
//

import Combine
import UIKit

class InputPassthroughView: UIView {
    weak var inputVc: InputViewController?

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let eventView = self.inputVc?.view else {
            return false
        }
        let p = self.convert(point, to: eventView)
        return eventView.point(inside: p, with: event)
    }
}

class ViewController: UIViewController {
    lazy var inputPassthroughView: InputPassthroughView = {
        let v = InputPassthroughView()
        v.backgroundColor = .clear
        return v
    }()

    let inputVc = InputViewController()
    let messageVc = MessageViewController()

    var inputVcHeightConstraint: NSLayoutConstraint!

    fileprivate var cancellables: Set<AnyCancellable> = Set()
    fileprivate var keyboarFrame: CGRect?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.title = "EM"

        self.setupNavigationBarAppearance()
        self.setupMessageVc()
        self.setupInputVc()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        self.inputVcHeightConstraint.constant = InputViewController.minHeight + self.view.safeAreaInsets.bottom
    }

    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .orange

        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.standardAppearance = appearance
        navigationBar?.scrollEdgeAppearance = appearance
    }

    func setupInputVc() {
        self.addChild(self.inputVc)
        self.inputPassthroughView.inputVc = self.inputVc
        self.view.addSubview(self.inputPassthroughView)
        self.inputPassthroughView.addSubview(self.inputVc.view)

        self.inputPassthroughView.translatesAutoresizingMaskIntoConstraints = false
        self.inputVc.view.translatesAutoresizingMaskIntoConstraints = false

        self.inputVcHeightConstraint = self.inputVc.view.heightAnchor.constraint(equalToConstant: InputViewController.minHeight + self.view.safeAreaInsets.bottom)

        NSLayoutConstraint.activate([
            self.inputPassthroughView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.inputPassthroughView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.inputPassthroughView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.inputPassthroughView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.inputVc.view.leadingAnchor.constraint(equalTo: self.inputPassthroughView.leadingAnchor),
            self.inputVc.view.trailingAnchor.constraint(equalTo: self.inputPassthroughView.trailingAnchor),
            self.inputVc.view.bottomAnchor.constraint(equalTo: self.inputPassthroughView.bottomAnchor),
            self.inputVcHeightConstraint,
        ])

        NotificationCenter.default
            .publisher(for: UIApplication.keyboardWillShowNotification)
            .sink { [weak self] in
                self?.keyboardWillShowHandle(notification: $0)
            }
            .store(in: &self.cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.keyboardWillHideNotification)
            .sink { [weak self] in
                self?.keyboardWillHideHandle(notification: $0)
            }
            .store(in: &self.cancellables)
    }

    func setupMessageVc() {
        self.addChild(self.messageVc)
        self.view.addSubview(self.messageVc.view)
        self.messageVc.view.translatesAutoresizingMaskIntoConstraints = false
        self.messageVc.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: InputViewController.minHeight + 20, right: 0)

        NSLayoutConstraint.activate([
            self.messageVc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.messageVc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.messageVc.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.messageVc.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(messageControllerTapHandler))
        self.messageVc.view.addGestureRecognizer(tap)
    }
}

private extension ViewController {
    @objc
    func messageControllerTapHandler() {
        self.view.endEditing(true)
    }

    func keyboardWillShowHandle(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        guard let keyboarFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        print("show", keyboarFrame)

        self.keyboarFrame = keyboarFrame

        let finalHeight = InputViewController.minHeight + keyboarFrame.height
        self.inputVcHeightConstraint.constant = finalHeight
        self.messageVc.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: finalHeight - self.view.safeAreaInsets.bottom + 20, right: 0)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            self.inputPassthroughView.layoutIfNeeded()
            self.messageVc.scrollToBottom(animated: true)
        }
    }

    func keyboardWillHideHandle(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        guard let keyboarFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        print("hidden", keyboarFrame)

        self.keyboarFrame = nil

        let finalHeight = InputViewController.minHeight + self.view.safeAreaInsets.bottom
        self.inputVcHeightConstraint.constant = finalHeight
        self.messageVc.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: InputViewController.minHeight + 20, right: 0)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            self.inputPassthroughView.layoutIfNeeded()
        }
    }
}
