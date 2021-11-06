//
//  TopTabBarController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 10/17/21.
//

import UIKit

class TopTabBarController: UIViewController {
    
    var tabSubviews: [UIView] = []
    let tabBarHeight: CGFloat = 60
    
    var tabBarView: TopTabBar!  // Might delete reference
    var blackBox: UIView!
    var shimmer: ShimmerAnimation!
    
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
//
//        createTabBar()
//
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let vcs: [UIViewController] = [
//            storyboard.instantiateViewController(withIdentifier: "VCOne"),
//            storyboard.instantiateViewController(withIdentifier: "VCTwo"),
//            storyboard.instantiateViewController(withIdentifier: "VCThree")
//        ]
        
//        let testVc = vcs.first!
//        let v = LibraryButtonView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        testVc.view.addSubview(v)
//        v.registerTouch()
//        NSLayoutConstraint.activate([
//            v.leadingAnchor.constraint(equalTo: testVc.view.leadingAnchor, constant: 20),
//            v.topAnchor.constraint(equalTo: testVc.view.topAnchor, constant: 20),
//            v.widthAnchor.constraint(equalToConstant: 200),
//            v.heightAnchor.constraint(equalToConstant: 200),
//        ])
        
//        let labels: [String] = ["Sources", "Extensions", "Migrate"]
//
//        for (headerLabel, vc) in zip(labels, vcs) {
//            addTabBarItem(withText: headerLabel, forViewController: vc)
//        }
        blackBox = UIView()
        view.addSubview(blackBox)
        blackBox.backgroundColor = UIColor(white: 0.0, alpha: 1)
        blackBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blackBox.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            blackBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            blackBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            blackBox.heightAnchor.constraint(equalTo: blackBox.widthAnchor)
        ])
        
        shimmer = ShimmerAnimation(onView: blackBox)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        shimmer.viewDidAppear()
    }
    
    func createTabBar() {
        tabBarView = TopTabBar()
        tabBarView.backgroundColor = .clear
        tabBarView.listener = self
        view.addSubview(tabBarView)
        tabBarView.initialize()
        
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.topAnchor.constraint(equalTo: view.topAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: tabBarHeight),
        ])
    }
    
    private func showViewWithoutAnimation(withIndex index: Int) {
        view.addSubview(tabSubviews[index])
        activateConstraints(forView: tabSubviews[index])
    }
    
    private func transition(to finalIndex: Int, onCompletion: (() -> Void)?) {
        guard finalIndex != selectedIndex else {return}
        
        guard finalIndex < tabSubviews.count else {return}
        
        let oldView = tabSubviews[selectedIndex]
        let newView = tabSubviews[finalIndex]
        
        // Whether the new view will slide in from the leading edge
        let fromLeading: Bool = finalIndex > selectedIndex
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        
        let oldViewFinalFrame = CGRect(
            x: fromLeading ? screenWidth : -screenWidth,
            y: oldView.frame.origin.y,
            width: oldView.bounds.width,
            height: oldView.bounds.height
        )
        
        let newViewInitialFrame = CGRect(
            x: fromLeading ? -screenWidth : screenWidth,
            y: oldView.frame.origin.y,
            width: oldView.bounds.width,
            height: oldView.bounds.height
        )
        
        newView.frame = newViewInitialFrame
        view.addSubview(newView)
        
        let newViewFinalFrame = oldView.frame
        
        UIView.animate(withDuration: 0.15, animations: {
            oldView.frame = oldViewFinalFrame
            newView.frame = newViewFinalFrame
        }, completion: {_ in
            self.activateConstraints(forView: newView)
            oldView.removeFromSuperview()
            self.selectedIndex = finalIndex
        })
    }
    
    private func activateConstraints(forView newSubview: UIView) {
        NSLayoutConstraint.activate([
            newSubview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            newSubview.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            newSubview.topAnchor.constraint(equalTo: self.tabBarView.bottomAnchor),
            newSubview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        ])
    }
    
    func addTabBarItem(withText text: String, forViewController vc: UIViewController) {
        tabBarView.addTabItem(withText: text)
        tabSubviews.append(vc.view)
        addChild(vc)
        vc.didMove(toParent: self)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        
        // If it doesn't have a view to unwrap then we have bigger problems than we can gracefully handle
        
        if tabSubviews.count == 1 {
            selectedIndex = 0  // Show the first view by default
            showViewWithoutAnimation(withIndex: 0)
        }
    }
}

extension TopTabBarController: TopTabBarListener {
    func displayView(withIndex index: Int) {
        transition(to: index, onCompletion: nil)
    }
}

protocol TopTabBarListener {  // There has to be a better way to do this
    func displayView(withIndex index: Int)
}

// MARK: TopTabBar
class TopTabBar: UIView {
    var selectedLineXConstraint: NSLayoutConstraint?
    var selectedLineWidthConstraint: NSLayoutConstraint?
    var listener: TopTabBarListener?
    
    var selectedLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 1
        view.backgroundColor = TopTabItem.selectedColor
        return view
    }()
    
    var selectedIdx: Int = 0 {
        willSet {
            guard selectedIdx < tabItemStackView.arrangedSubviews.count,
                  let tabItem = tabItemStackView.arrangedSubviews[selectedIdx] as? TopTabItem else {return}
            tabItem.tabItemSelected = false
        }
        didSet {
            guard selectedIdx < tabItemStackView.arrangedSubviews.count,
                  let tabItem = tabItemStackView.arrangedSubviews[selectedIdx] as? TopTabItem else {return}
            tabItem.tabItemSelected = true
            updateSelectedLineConstraints()
        }
    }
    
    var tabItemStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .bottom
        return sv
    }()
    
    private func updateSelectedLineConstraints() {
        let beneathView = tabItemStackView.arrangedSubviews[selectedIdx]
        guard let xConstraint = selectedLineXConstraint,
              let widthConstraint = selectedLineWidthConstraint,
              let beneathView = beneathView as? TopTabItem else {return}
        
        UIView.animate(withDuration: 0.15) {
            self.removeConstraints([xConstraint, widthConstraint])
            
            self.selectedLineXConstraint = NSLayoutConstraint(item: self.selectedLine, attribute: .centerX, relatedBy: .equal, toItem: beneathView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            self.selectedLineWidthConstraint = NSLayoutConstraint(item: self.selectedLine, attribute: .width, relatedBy: .equal, toItem: beneathView.customLabel, attribute: .width, multiplier: 1.0, constant: 0.0)
            self.addConstraint(self.selectedLineXConstraint!)
            self.addConstraint(self.selectedLineWidthConstraint!)
            self.layoutIfNeeded()
        }
    }
    
    func initialize() {
        addSubview(tabItemStackView)
        addSubview(selectedLine)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedLine.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            selectedLine.heightAnchor.constraint(equalToConstant: 3),
            
            tabItemStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tabItemStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tabItemStackView.bottomAnchor.constraint(equalTo: selectedLine.topAnchor),
            tabItemStackView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
    }
    
    
    func addTabItem(withText text: String) {
        // TODO: possible make this a subview. idk if stackview handles passing responder events forward
        let newItem = TopTabItem()
        newItem.populate(withText: text)
        newItem.tag = tabItemStackView.arrangedSubviews.count
        newItem.addTarget(self, action: #selector(buttonTarget), for: .touchUpInside)
        tabItemStackView.addArrangedSubview(newItem)
        
        if tabItemStackView.arrangedSubviews.count == 1 {
            selectedLineXConstraint = NSLayoutConstraint(item: selectedLine, attribute: .centerX, relatedBy: .equal, toItem: newItem, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            selectedLineWidthConstraint = NSLayoutConstraint(item: selectedLine, attribute: .width, relatedBy: .equal, toItem: newItem.customLabel, attribute: .width, multiplier: 1.0, constant: 0.0)
            self.addConstraint(selectedLineXConstraint!)
            self.addConstraint(selectedLineWidthConstraint!)
        }
    }
    
    @objc func buttonTarget(_ sender: UIButton?) {
        guard let senderTabItem = sender as? TopTabItem else {
            print("Guard Failed: cast responder sender to TopTabItem")
            return
        }
        
        selectedIdx = senderTabItem.tag
        listener?.displayView(withIndex: selectedIdx)
    }
}


// MARK: TopTabItem
class TopTabItem: UIButton {

    static let unselectedColor: UIColor = UIColor(red: 0.7451, green: 0.7725, blue: 0.7765, alpha: 1.0)
    static let selectedColor: UIColor = UIColor(red: 0.1882, green: 0.4000, blue: 0.7451, alpha: 1.0)
    
    
    var customLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 1
        l.contentMode = .center
        l.font = UIFont.systemFont(ofSize: 16)
        l.textColor = unselectedColor
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    
    var tabItemSelected: Bool = false {
        didSet {
            customLabel.textColor = tabItemSelected ? TopTabItem.selectedColor : TopTabItem.unselectedColor
        }
    }
    
    var textWidthAnchor: NSLayoutDimension {
        get {
            return customLabel.widthAnchor
        }
    }
    
    
    func populate(withText text: String) {
        customLabel.text = text
        
        addSubview(customLabel)

        NSLayoutConstraint.activate([
            customLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),  // Label 10 pt above bottom line
            customLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
