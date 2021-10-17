//
//  SpecialTabBar.swift
//  UselessTableViewApp
//
//  Created by Aramis on 10/11/21.
//

import UIKit

class SpecialTabBar: UITabBar {
    
    var customItems: [SpecialTabBarItem] = []
    
    override var tintColor: UIColor! {
        didSet {
            for item in customItems {
                item.color = tintColor
            }
        }
    }
    
//    convenience init(withItems items: [SpecialTabBarItem]) {
//        self.init(withItems: items)
//        customItems = items
//        translatesAutoresizingMaskIntoConstraints = false
//
//        addStyle()
//    }
    
    func populateView(withItems items: [SpecialTabBarItem]) {
        customItems = items
        translatesAutoresizingMaskIntoConstraints = false
        
        // Clear default subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        addStyle()  // will insert our own subviews
    }
    
    
    private func addStyle() {
        backgroundColor = .white
        
        if customItems.isEmpty {
            return
        }
        
        // Create horizontal line across top of tabbar:
        let hline: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.5))
        hline.backgroundColor = .lightGray
        addSubview(hline)
        hline.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            hline.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            hline.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            hline.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            hline.topAnchor.constraint(equalTo: self.topAnchor),
//            hline.widthAnchor.constraint(equalTo: self.widthAnchor),
            hline.heightAnchor.constraint(equalToConstant: 0.5),
        ])
        
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = screenWidth / CGFloat(customItems.count)
        
        var layoutFormat = "H:|"
        var viewsDict: [String: SpecialTabBarItem] = [:]
        
        for (n, item) in customItems.enumerated() {
            addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
            var constraints: [NSLayoutConstraint] = []
            
            if item.itemHeight == 0 {
                constraints += [
                    item.topAnchor.constraint(equalTo: self.topAnchor),
                    item.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                ]
            } else {
                constraints += [
                    item.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    item.heightAnchor.constraint(equalToConstant: item.itemHeight),
                ]
            }
            constraints.append(item.widthAnchor.constraint(equalToConstant: itemWidth))
            NSLayoutConstraint.activate(constraints)
            
            layoutFormat += "[v\(n)]"
            viewsDict["v\(n)"] = item
        }
        layoutFormat += "|"
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: layoutFormat, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views:viewsDict))
    }
}
