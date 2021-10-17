//
//  SpecialTabViewController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 10/11/21.
//

import UIKit

class SpecialTabViewController: UITabBarController {
    
    var customTabBar: SpecialTabBar = SpecialTabBar()
    var unselectedColor: UIColor = .black
    var selectedColor: UIColor = .blue {
        didSet {
            guard let customTabBar = tabBar as? SpecialTabBar else {return}
            customTabBar.tintColor = selectedColor
        }
    }

    private let tabBarHeight: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
         tabBar.isHidden = true
        // addStyle()
        view.translatesAutoresizingMaskIntoConstraints = false
        setupView()
    }
    
    
    private func setupView() {
        let leftImage = UIImage(systemName: "square.and.arrow.up")
        let leftText = "Export"
        
        let middleImage = UIImage(systemName: "folder")
        let middleText = ""
       
        let rightImage = UIImage(systemName: "square.and.arrow.down")
        let rightText = "Import"
        
        guard let leftImageUnwrapped = leftImage,
              let middleImageUnwrapped = middleImage,
              let rightImageUnwrapped = rightImage else {
                  print("Images not found")
                  return
              }
        
        
        let leftItem = SpecialTabBarItem(withIcon: leftImageUnwrapped, withText: leftText)
        let middleItem = SpecialTabBarItem(withIcon: middleImageUnwrapped, withText: middleText)
        let rightItem = SpecialTabBarItem(withIcon: rightImageUnwrapped, withText: rightText)
        
        populateTabBar(withItems: [leftItem, middleItem, rightItem])
    }
    
    
    func populateTabBar(withItems tabBarItems: [SpecialTabBarItem]) {
        guard tabBarItems.count > 0 else {return}
        
        customTabBar.populateView(withItems: tabBarItems)
        customTabBar.tintColor = unselectedColor
        customTabBar.customItems.first?.color = selectedColor
        
        view.addSubview(customTabBar)
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: tabBarHeight),
        ])
        
        for (n, item) in customTabBar.customItems.enumerated() {
            item.tag = n
            item.addTarget(self, action: #selector(selectTab), for: .touchUpInside)
        }
    }
    
    
    @objc func selectTab(fromButton button: UIButton) {
        selectedIndex = button.tag
        print(selectedIndex)
    }

}
