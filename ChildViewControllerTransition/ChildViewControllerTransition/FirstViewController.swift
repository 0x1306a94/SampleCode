//
//  FirstViewController.swift
//  ChildViewControllerTransition
//
//  Created by king on 2021/5/8.
//

import UIKit

class FirstViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		view.backgroundColor = .red
		print("\(type(of: self)) \(#function)")
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		print("\(type(of: self)) \(#function)")
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		print("\(type(of: self)) \(#function)")
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		print("\(type(of: self)) \(#function)")
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		print("\(type(of: self)) \(#function)")
	}
}
