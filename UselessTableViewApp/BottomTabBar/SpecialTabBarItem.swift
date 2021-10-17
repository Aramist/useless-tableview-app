//
//  SpecialTabBarItem.swift
//  UselessTableViewApp
//
//  Created by Aramis on 10/11/21.
//

import UIKit

class SpecialTabBarItem: UIButton {
    
    
    var itemHeight: CGFloat = 0.0
    var lock: Bool = false
    
    let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let textLabel: UILabel = {
        var l = UILabel()
        l.numberOfLines = 1
        l.textAlignment = .center
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 11)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // might be removed
    var color: UIColor = .black {
        didSet {
            textLabel.textColor = color
        }
    }
    
    convenience init(withIcon icon: UIImage, withText title: String, withFont font: UIFont = UIFont.systemFont(ofSize: 11)) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.image = icon
        textLabel.text = title
        textLabel.font = font
        
        
        addSubview(iconImageView)
        addSubview(textLabel)
        
        // Give the image more area if there is no text
        let textImageGap: CGFloat = title == "" ? 2.0 : 20.0
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            iconImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -textImageGap),
            iconImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
            textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textLabel.heightAnchor.constraint(equalToConstant: 6)
        ])
    }
}
