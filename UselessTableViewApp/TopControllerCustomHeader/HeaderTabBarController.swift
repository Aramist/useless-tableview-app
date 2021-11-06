//
//  HeaderTabBarController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 10/17/21.
//

import UIKit

class HeaderTabBarController: UIViewController {

    var delegate: TabBarHeaderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}


// MARK: Header delegate
protocol TabBarHeaderDelegate {
    func headerView(forTabBarController controller: HeaderTabBarController) -> UIView
}


class HeaderTabBar: UIView {
    
}
