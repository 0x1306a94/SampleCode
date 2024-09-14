//
//  ViewController.swift
//  CustomTabBarSample
//
//  Created by king on 2024/9/14.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func pushAction(_ sender: UIButton) {
        let vc = UIViewController()
        vc.view.backgroundColor = .brown
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
