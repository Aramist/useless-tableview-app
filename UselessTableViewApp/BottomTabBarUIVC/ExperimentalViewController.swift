//
//  ExperimentalViewController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 10/14/21.
//

import UIKit

class ExperimentalViewController: UIViewController {

    var tabSubviews: [UIView] = []
    let tabBarHeight: CGFloat = 50
    
    var tabBarView: UIView!  // Might delete reference
    var tabBarStackView: UIStackView!
    
    var selectedIndex: Int = 0 {
        willSet {
            hideView()
        }
        didSet {
            showView()
        }
    }
    
    
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
        
        
        let icons: [ExperimentalTabIcon] = [
            ExperimentalTabIcon(),
            ExperimentalTabIcon(),
            ExperimentalTabIcon(),
        ]
        
        icons[0].populate(withImage: UIImage(systemName: "trash")!, withText: "", withFont: nil)
        icons[1].populate(withImage: UIImage(systemName: "person.circle")!, withText: "", withFont: nil)
        icons[2].populate(withImage: UIImage(systemName: "paperplane")!, withText: "", withFont: nil)
        
        for (tbItem, vc) in zip(icons, vcs) {
            addTabBarItem(tbItem, forViewController: vc)
        }
    }
    
    func createTabBar() {
        tabBarView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tabBarView.backgroundColor = .lightGray
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarView)
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: tabBarHeight),
        ])
        
        tabBarStackView = UIStackView()
        tabBarStackView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.addSubview(tabBarStackView)
        NSLayoutConstraint.activate([
            tabBarStackView.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            tabBarStackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor),
            tabBarStackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor),
            tabBarStackView.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor),
        ])
        tabBarStackView.axis = .horizontal
        tabBarStackView.distribution = .fillEqually
        tabBarStackView.alignment = .bottom
    }
    
    private func hideView() {
        tabSubviews[selectedIndex].isHidden = true
    }
    
    private func showView() {
        tabSubviews[selectedIndex].isHidden = false
    }
    
    func addTabBarItem(_ item: ExperimentalTabIcon, forViewController vc: UIViewController) {
        tabBarStackView.addArrangedSubview(item)
        item.tag = tabBarStackView.arrangedSubviews.count - 1
        item.addTarget(self, action: #selector(changeSelected), for: .touchUpInside)
        
        // Configure the parent-child relationship. Important
        tabSubviews.append(vc.view)
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            vc.view.topAnchor.constraint(equalTo: self.tabBarView.bottomAnchor),
        ])
        
        vc.view.isHidden = true  // Hidden by default
        
        // If this is the only view present, make it the selected
        
        if tabSubviews.count == 1 {
            updateSelectedColor(forNewIndex: 0)
            showView()
        }
    }
    
    func updateSelectedColor(forNewIndex idx: Int) {
        let oldTabItem = tabBarStackView.arrangedSubviews[self.selectedIndex] as? ExperimentalTabIcon
        oldTabItem?.tabItemSelected = false
        self.selectedIndex = idx
        let newTabItem = tabBarStackView.arrangedSubviews[self.selectedIndex] as? ExperimentalTabIcon
        newTabItem?.tabItemSelected = true
    }
    
    @objc func changeSelected(sender: UIButton?) {
        guard let unwrappedSender = sender else {return}
        updateSelectedColor(forNewIndex: unwrappedSender.tag)
    }
}


class ExperimentalTabIcon: UIButton {
    
    let selectLineColor: UIColor = .systemBlue
    
    var icon: UIImageView = {
        let im = UIImageView()
        im.contentMode = .scaleAspectFill
        im.clipsToBounds = true
        im.translatesAutoresizingMaskIntoConstraints = false
        return im
    }()
    
    var customLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 1
        l.contentMode = .center
        l.font = UIFont.systemFont(ofSize: 11)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    var selectedLine: UIView = {
        let l = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.5))
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isHidden = true
        return l
    }()
    
    var tabItemSelected: Bool = false {
        didSet {
            selectedLine.isHidden = !tabItemSelected
        }
    }
    
    
    func populate(withImage image: UIImage, withText text: String, withFont font: UIFont? = nil) {
        icon.image = image
        customLabel.text = text
        selectedLine.backgroundColor = selectLineColor
        
        addSubview(icon)
        addSubview(customLabel)
        addSubview(selectedLine)
        
        // When the text is nonempty, more space is placed between the image and the text, making the image smaller
        let imageYOffset: CGFloat = text == "" ? -2 : -20
        
        // The width of the image is determined by the presence of text and the height of the tab bar
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor),  // Ratio: 1
            icon.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            icon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            customLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6),  // Label 6pt above bottom
            customLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            icon.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: imageYOffset),
            
            selectedLine.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            selectedLine.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            selectedLine.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.75),
        ])
    }
}
