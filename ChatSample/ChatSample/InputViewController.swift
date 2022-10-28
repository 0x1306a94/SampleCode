//
//  InputViewController.swift
//  ChatSample
//
//  Created by king on 2022/10/28.
//

import Combine
import UIKit

protocol InputViewControllerDelegate: NSObjectProtocol {
    func inputViewController(controller: InputViewController, didUpdateHeight height: CGFloat, duration: TimeInterval)
}

class InputViewController: UIViewController {
    static let minHeight: CGFloat = 66

    weak var delegate: InputViewControllerDelegate?

    fileprivate lazy var textView: UITextView = {
        let v = UITextView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 6

        return v
    }()

    fileprivate var cancellables: Set<AnyCancellable> = Set()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.view.backgroundColor = UIColor(named: "backgroundColor")

        self.setupLineView()
        self.setupTextView()
    }

    func setupLineView() {
        let v = UIView()
        v.backgroundColor = UIColor(named: "lineColor")
        v.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(v)
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            v.topAnchor.constraint(equalTo: self.view.topAnchor),
            v.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
        ])
    }

    func setupTextView() {
        self.view.addSubview(self.textView)
        self.textView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            self.textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            self.textView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            self.textView.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
}

private extension InputViewController {}
