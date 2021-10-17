//
//  TopTabBarController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 10/17/21.
//

import UIKit

class TopTabBarController: UIViewController {
    
    var tabSubviews: [UIView] = []
    var vcHorizontalConstraints: [NSLayoutConstraint] = []
    let tabBarHeight: CGFloat = 60
    
    var tabBarView: TopTabBar!  // Might delete reference
    
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        createTabBar()
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vcs: [UIViewController] = [
            storyboard.instantiateViewController(withIdentifier: "VCOne"),
            storyboard.instantiateViewController(withIdentifier: "VCTwo"),
            storyboard.instantiateViewController(withIdentifier: "VCThree")
        ]
        
        let labels: [String] = ["Sources", "Extensions", "Migrate"]
        
        for (headerLabel, vc) in zip(labels, vcs) {
            addTabBarItem(withText: headerLabel, forViewController: vc)
        }
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
    
    private func hideView() {
        tabSubviews[selectedIndex].isHidden = true
//        view.backgroundColor = .white
    }
    
    private func showView() {
        tabSubviews[selectedIndex].isHidden = false
//        view.backgroundColor = tabSubviews[selectedIndex].backgroundColor
    }
    
    private func transition(to finalIndex: Int, onCompletion: (() -> Void)?) {
        guard finalIndex != selectedIndex else {
            hideView()
            selectedIndex = finalIndex
            showView()
            return
        }
        
        guard finalIndex < tabSubviews.count else {return}
        
        let oldView = tabSubviews[selectedIndex]
        let newView = tabSubviews[finalIndex]
        
        
        // Whether the new view enters from the leading side
        let fromLeading = finalIndex < selectedIndex
        let firstAttribute: NSLayoutConstraint.Attribute = fromLeading ? .trailing : .leading,
            secondAttribute: NSLayoutConstraint.Attribute = fromLeading ? .leading : .trailing
        let prePositioning = NSLayoutConstraint(item: newView, attribute: firstAttribute, relatedBy: .equal, toItem: self.view, attribute: secondAttribute, multiplier: 1.0, constant: 0.0)
        let newViewPosition = NSLayoutConstraint(item: newView, attribute: firstAttribute, relatedBy: .equal, toItem: self.view, attribute: firstAttribute, multiplier: 1.0, constant: 0.0)
        // Note that first and second attribute are swapped here:
        let oldViewOffScreen = NSLayoutConstraint(item: oldView, attribute: secondAttribute, relatedBy: .equal, toItem: self.view, attribute: firstAttribute, multiplier: 1.0, constant: 0.0)
        
        
        // The array should hold the active steady-state constraints, not any inactive constraints
        let oldViewInitialConstraint = vcHorizontalConstraints[selectedIndex]
        self.view.removeConstraint(oldViewInitialConstraint)  // Remove old view old constraint to reposition
        // Keep the array updated with active constraints (assuming completion of the animation)
        self.vcHorizontalConstraints[selectedIndex] = oldViewOffScreen
        self.vcHorizontalConstraints[finalIndex] = newViewPosition
        // Place the new view off-screen
        self.view.addConstraint(prePositioning)
        newView.isHidden = false
        selectedIndex = finalIndex
        self.view.layoutIfNeeded()
        // TODO: Possible call layout if needed here, before the animation begins
        
        UIView.animate(withDuration: 0.1, animations: {
            self.view.removeConstraint(prePositioning)
            self.view.addConstraint(newViewPosition)
            self.view.removeConstraint(oldViewInitialConstraint)
            self.view.addConstraint(oldViewOffScreen)
            self.view.layoutIfNeeded()
        }, completion: { _ in
            oldView.isHidden = true
            onCompletion?()
        })
    }
    
    func addTabBarItem(withText text: String, forViewController vc: UIViewController) {
        tabBarView.addTabItem(withText: text)
        tabSubviews.append(vc.view)
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            vc.view.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            vc.view.topAnchor.constraint(equalTo: self.tabBarView.bottomAnchor),
        ])
        
        // If it doesn't have a view to unwrap then we have bigger problems than we can gracefully handle
        let horizConstraint = NSLayoutConstraint(item: vc.view!, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        
        self.view.addConstraint(horizConstraint)
        vcHorizontalConstraints.append(horizConstraint)
        
        vc.view.isHidden = true  // Hidden by default
        
        if tabSubviews.count == 1 {
            selectedIndex = 0  // Show the first view by default
            showView()
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
        
        UIView.animate(withDuration: 0.1) {
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
