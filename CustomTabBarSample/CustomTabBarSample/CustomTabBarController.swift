//
//  CustomTabBarController.swift
//  CustomTabBarSample
//
//  Created by king on 2024/9/14.
//

import UIKit

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBar = CustomTabBar()
        self.setValue(tabBar, forKey: "tabBar")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
    }
}
