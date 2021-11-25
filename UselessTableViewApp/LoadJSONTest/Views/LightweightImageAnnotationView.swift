//
//  LightweightImageAnnotationView.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/20/21.
//

import MapKit
import UIKit

class LightweightImageAnnotationView: MKAnnotationView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    public static let reuseID = "LightweightImageAnnotationView"
    
    var radius: CGFloat = 5
    let circle: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        v.backgroundColor = .imperialRed
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let inner = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        inner.backgroundColor = .white
        inner.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.widthAnchor.constraint(equalTo: v.widthAnchor, multiplier: 0.5),
            inner.heightAnchor.constraint(equalTo: v.heightAnchor, multiplier: 0.5),
            inner.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            inner.centerYAnchor.constraint(equalTo: v.centerYAnchor)
        ])
        return v
    }()
    
    var childAnnotationView: ImageAnnotationView?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        arrangeSubview()
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let annotation = annotation as? ImageGroup else {return}
        childAnnotationView?.prepareForDisplay(withAnnotation: annotation)
        isEnabled = false
        centerOffset = CGPoint(x: bounds.width / 2, y: -bounds.height / 2)
    }
    
    func updateOffset() {
        centerOffset = CGPoint(x: bounds.width / 2, y: -bounds.height / 2)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        childAnnotationView?.prepareForReuse()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func activate() {
        childAnnotationView?.show()
        isEnabled = true
    }
    
    func deactivate() {
        childAnnotationView?.hide()
        isEnabled = false
    }
    
    fileprivate func arrangeSubview() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(circle)
        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: radius * 2),
            circle.heightAnchor.constraint(equalToConstant: radius * 2),
            circle.centerXAnchor.constraint(equalTo: leadingAnchor),
            circle.centerYAnchor.constraint(equalTo: bottomAnchor)
        ])
        circle.layer.cornerRadius = radius
        circle.subviews.first?.layer.cornerRadius = radius / 2
        
        let child = ImageAnnotationView()
        childAnnotationView = child
        addSubview(child)
        
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: leadingAnchor),
            child.bottomAnchor.constraint(equalTo: bottomAnchor),
            child.widthAnchor.constraint(equalTo: widthAnchor),
            child.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
}
