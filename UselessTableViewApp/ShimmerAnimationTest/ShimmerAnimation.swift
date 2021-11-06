//
//  ShimmerAnimationView.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/5/21.
//

import UIKit

class ShimmerAnimation {
    
    var layer: CAGradientLayer
    weak var parent: UIView?
    var parentCopy: UIView
    
    
    init(onView view: UIView) {
        parent = view
        parentCopy = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        parentCopy.backgroundColor = .white
        parentCopy.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(parentCopy)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: parentCopy.topAnchor),
            view.bottomAnchor.constraint(equalTo: parentCopy.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: parentCopy.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parentCopy.trailingAnchor)
        ])
        
        layer = CAGradientLayer()
    }
    
    func viewDidAppear(){
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor(white: 1.0, alpha: 0.4).cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 0.5, 1]
        layer.startPoint = CGPoint(x: 0, y: 0.2)
        layer.endPoint = CGPoint(x: 0, y: 0.8)
        
        layer.frame = CGRect(
            x: parentCopy.bounds.origin.x,
            y: parentCopy.bounds.origin.y,
            width: parentCopy.bounds.width * 2,
            height: parentCopy.bounds.height
        )
        
        let angle = -60 * CGFloat.pi / 180.0
        layer.transform = CATransform3DTranslate(
            CATransform3DMakeRotation(angle, 0, 0, 1),
            0, 0, 0)
        print(layer.bounds.height)
        parentCopy.layer.mask = layer
        
        let anim = CABasicAnimation(keyPath: "transform.translation.x")
        anim.duration = 3
        anim.fromValue = -parentCopy.frame.width * 3
        anim.toValue = parentCopy.frame.width * 4
        anim.repeatCount = Float.infinity
        layer.add(anim, forKey: "slideAnimation")
        
    }
    
    deinit {
        parent?.layer.mask = nil
        print("deinit")
    }

}
